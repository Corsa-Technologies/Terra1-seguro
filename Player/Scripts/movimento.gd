extends CharacterBody2D

var SPEED = 300.0
const JUMP_VELOCITY = -450.0
var canjump := true
var is_shooting = false # Variável para controlar se o personagem está atirando
var is_attacking = false # Variável para controlar se o personagem está atacando
var is_healing = false # Variável para controlar se o personagem está curando
var heal_count: int = 5 # Número de curas disponíveis
var speed_dash = 600
var dash_time = 0.2 # tempo do dash em segundos
var is_dashing = false
var dash_cooldown_time = 1.0  # Cooldown entre dashes em segundos
var can_dash = true  # Controla se o jogador pode dash

@onready var coyote_timer = $CoyoteTimer as Timer
@onready var animated_sprite = $AnimatedSprite2D # Referência ao AnimatedSprite2D
@onready var health_label = $ControleTouch/Control/HealthText # Referência ao Label de vida
@onready var hitboxlamina = $hitboxlamina # Referência à hitboxlamina
@onready var heal_timer = Timer.new() # Temporizador para controlar a duração da animação de cura
@onready var heal_count_label = $ControleTouch/Control/HealCountText # Referência ao Label de cura

@export var buffer_time: float = 0.15
@export var coyote_time: float = 0.1
@export var projectile_scene: PackedScene # A cena do projétil que será instanciada

func update_heal_display():
	if heal_count_label:  # Verifica se a referência não é null
		heal_count_label.text = " " + str(PlayerData.heals_available)  # Mostra as curas restantes

# Variáveis para a vida
var max_health: int = 100
var current_health: int = 100

var jump_buffered = false
var buffer_timer = 0.0

func _ready():
	coyote_timer.wait_time = coyote_time
	current_health = PlayerData.player_health  # Pega a vida do singleton
	update_health_display() # Atualiza a exibição da vida no início
	update_heal_display() # Atualiza a exibição da contagem de cura
	hitboxlamina.set_monitoring(false) # Desativa a hitbox no início
	add_child(heal_timer)
	heal_timer.wait_time = 1.0
	heal_timer.one_shot = true
	heal_timer.connect("timeout", Callable(self, "_on_heal_animation_finished"))



# Função para receber dano
func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	PlayerData.player_health = current_health  # Salva a vida atual no singleton
	update_health_display()
	if current_health <= 0:
		die()  # Chama a função de morte

# Atualizar a exibição de vida no LabelText
func update_health_display():
	health_label.text = str(current_health) + "/" + str(max_health)

# Função de cura
func heal():
	if not is_healing and PlayerData.heals_available > 0:  # Verifica se não está curando e se há curas disponíveis
		current_health = max_health
		update_health_display()
		PlayerData.heals_available -= 1  # Reduz a contagem de curas no singleton
		update_heal_display()  # Atualiza a exibição da contagem de cura
		is_healing = true
		animated_sprite.play("cura")  # Toca a animação de cura
		heal_timer.start()  # Começa o temporizador para finalizar a animação


# Função chamada quando a animação de cura termina
func _on_heal_animation_finished():
	is_healing = false
	animated_sprite.play("idle") # Volta para a animação idle após a cura

# Função de pulo
func pular():
	velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("dash") and not is_dashing:
		dash()

	# Verifica se o botão de cura foi apertado
	if Input.is_action_just_pressed("cura"):
		heal()

	# Impede movimentação lateral e pulo durante a cura, mas permite cair
	if is_healing:
		velocity.x = 0 # Impede que o jogador se mova lateralmente
		# Não retornamos aqui para permitir que a gravidade atue
	else:
		# Suporta o "jump buffer"
		if Input.is_action_just_pressed("ui_up") and not is_shooting and not is_attacking:
			jump_buffered = true
			buffer_timer = buffer_time

		# Diminui o tempo do jump buffer
		if jump_buffered:
			buffer_timer -= delta
			if buffer_timer <= 0.0:
				jump_buffered = false

		# Suporta o pulo, incluindo o coyote time
		if jump_buffered and canjump and not is_shooting and not is_attacking:
			pular()
			jump_buffered = false
			canjump = false

		# Reseta a variável canjump quando pisa no chão
		if is_on_floor():
			canjump = true
			if not coyote_timer.is_stopped():
				coyote_timer.stop()

		# Adiciona o efeito coyote time
		if canjump and coyote_timer.is_stopped() and not is_on_floor():
			coyote_timer.start()

		# Lógica de movimentação, somente se não estiver atirando ou atacando
		if not is_shooting and not is_attacking:
			var direction := Input.get_axis("ui_left", "ui_right")
			if direction != 0:
				velocity.x = direction * SPEED
				if is_on_floor():
					animated_sprite.play("run") # Troca para animação de corrida se estiver no chão e se movendo
				animated_sprite.flip_h = direction < 0 # Inverte o sprite se estiver movendo para a esquerda
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if is_on_floor():
					animated_sprite.play("idle") # Troca para animação de idle se estiver parado no chão e não curando

			# Se o personagem estiver no ar, toca a animação de pulo.
			if not is_on_floor():
				animated_sprite.play("jump")

		# Ajuste a posição da hitbox com base na direção do player
		if is_attacking:
			if animated_sprite.flip_h:  # Se o sprite estiver virado para a esquerda
				hitboxlamina.position.x = -8  # Ajuste a posição para a esquerda (valor negativo)
			else:
				hitboxlamina.position.x = 10  # Ajuste a posição para a direita (valor positivo)

	move_and_slide()



func dash():
	is_dashing = true
	var original_speed = SPEED  # Guarda a velocidade original
	SPEED = speed_dash  # Aumenta a velocidade para o dash

	# Usa await para esperar o tempo do dash
	await get_tree().create_timer(dash_time).timeout
	SPEED = original_speed  # Retorna à velocidade original após o dash
	is_dashing = false



# Função que lida com inputs de tiro e ataque
func _input(event: InputEvent):
	if event.is_action_pressed("ui_down") and is_on_floor():
		position.y += 1

	# Verifica se o botão "tiro" foi pressionado e o personagem não está atirando ou atacando
	if event.is_action_pressed("tiro") and not is_shooting and not is_attacking and not is_healing:
		is_shooting = true
		velocity.x = 0 # Para o personagem de se mover enquanto atira
		animated_sprite.play("tiro")
		shoot_projectile() # Dispara o projétil
		animated_sprite.connect("animation_finished", Callable(self, "_on_shoot_animation_finished"))

	# Verifica se o botão "ataque" foi pressionado e o personagem não está atacando ou atirando
	if event.is_action_pressed("ataque") and not is_attacking and not is_shooting and not is_healing:
		is_attacking = true
		velocity.x = 0 # Para o personagem de se mover enquanto ataca
		animated_sprite.play("ataque")
		hitboxlamina.set_monitoring(true)  # Ativa a hitbox ao iniciar o ataque
		animated_sprite.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

# Função chamada quando a animação de tiro termina
func _on_shoot_animation_finished():
	is_shooting = false
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_shoot_animation_finished"))

# Função chamada quando a animação de ataque termina
func _on_attack_animation_finished():
	is_attacking = false
	hitboxlamina.set_monitoring(false)  # Desativa a hitbox ao terminar o ataque
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_attack_animation_finished"))

# Função para disparar o projétil
func shoot_projectile():
	# Verifica se a cena do projétil foi atribuída
	if projectile_scene == null:
		return
	
	# Instancia a cena do projétil
	var projectile = projectile_scene.instantiate() as CharacterBody2D
	
	# Define a posição inicial do projétil um pouco à frente do jogador
	if animated_sprite.flip_h:
		projectile.global_position = global_position + Vector2(-10, 0)  # Dispara para a esquerda
		projectile.direction = Vector2.LEFT  # Define a direção para a esquerda
	else:
		projectile.global_position = global_position + Vector2(10, 0)  # Dispara para a direita
		projectile.direction = Vector2.RIGHT  # Define a direção para a direita
	
	# Adiciona o projétil à cena
	get_parent().add_child(projectile)

# Função de morte
func die():
	current_health = 100  # Restaura a vida para 100 ao morrer
	PlayerData.player_health = current_health  # Atualiza o valor no singleton
	update_health_display()  # Atualiza a exibição da vida
	get_tree().reload_current_scene()

# Função para quando o tempo do coyote timer acaba
func _on_coyote_timer_timeout() -> void:
	canjump = false

# Função de colisão
func _on_hitboxlamina_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		var hurtbox = body.get_node("hurtbox")
		if hurtbox:
			hurtbox.get_parent().take_damage(50)
