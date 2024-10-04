extends CharacterBody2D

var SPEED = 300.0
const JUMP_VELOCITY = -450.0
var canjump := true
var is_shooting = false # Variável para controlar se o personagem está atirando
var is_attacking = false # Variável para controlar se o personagem está atacando
@onready var coyote_timer = $CoyoteTimer as Timer
@onready var animated_sprite = $AnimatedSprite2D # Referência ao AnimatedSprite2D
@onready var health_label = $ControleTouch/Control/HealthText # Referência ao Label de vida
@export var buffer_time: float = 0.15
@export var coyote_time: float = 0.1

# Variáveis para a vida
var max_health: int = 100
var current_health: int = 100

var jump_buffered = false
var buffer_timer = 0.0

func _ready():
	coyote_timer.wait_time = coyote_time
	update_health_display() # Atualiza a exibição da vida no início

func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_health_display()
	
	if current_health <= 0:
		die() # Implementar a lógica de morte se necessário

func heal(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	update_health_display()

func update_health_display():
	health_label.text = str(current_health) + "/" + str(max_health)

func pular():
	velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Suporta o "jump buffer".
	if Input.is_action_just_pressed("ui_up") and not is_shooting and not is_attacking:
		jump_buffered = true
		buffer_timer = buffer_time

	# Diminui o tempo do jump buffer.
	if jump_buffered:
		buffer_timer -= delta
		if buffer_timer <= 0.0:
			jump_buffered = false

	# Suporta o pulo, incluindo o coyote time.
	if jump_buffered and canjump and not is_shooting and not is_attacking:
		pular()
		jump_buffered = false
		canjump = false

	# Reseta a variável canjump quando pisa no chão.
	if is_on_floor():
		canjump = true
		if not coyote_timer.is_stopped():
			coyote_timer.stop()

	# Adiciona o efeito coyote time.
	if canjump and coyote_timer.is_stopped() and not is_on_floor():
		coyote_timer.start()

	# Lógica de movimentação, somente se não estiver atirando ou atacando.
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
				animated_sprite.play("idle") # Troca para animação de idle se estiver parado no chão

		# Se o personagem estiver no ar, toca a animação de pulo.
		if not is_on_floor():
			animated_sprite.play("jump")
	
	move_and_slide()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_down") and is_on_floor():
		position.y += 1

	# Verifica se o botão "tiro" foi pressionado e o personagem não está atirando ou atacando
	if event.is_action_pressed("tiro") and not is_shooting and not is_attacking:
		is_shooting = true
		velocity.x = 0 # Para o personagem de se mover enquanto atira
		animated_sprite.play("tiro")
		# Conecta o sinal de "animation_finished" com a função que será chamada quando a animação terminar
		animated_sprite.connect("animation_finished", Callable(self, "_on_shoot_animation_finished"))

	# Verifica se o botão "ataque" foi pressionado e o personagem não está atirando ou atacando
	if event.is_action_pressed("ataque") and not is_attacking and not is_shooting:
		is_attacking = true
		velocity.x = 0 # Para o personagem de se mover enquanto ataca
		animated_sprite.play("ataque")
		# Conecta o sinal de "animation_finished" com a função que será chamada quando a animação de ataque terminar
		animated_sprite.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func _on_shoot_animation_finished():
	# Quando a animação de tiro termina, voltamos ao estado normal
	is_shooting = false
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_shoot_animation_finished"))

func _on_attack_animation_finished():
	# Quando a animação de ataque termina, voltamos ao estado normal
	is_attacking = false
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func _on_coyote_timer_timeout() -> void:
	canjump = false

# Adicione uma função para a lógica de morte, se necessário
func die():
	print("O jogador morreu!")  # Mensagem de depuração
	queue_free()  # Remove o jogador da cena (ou outra lógica de morte)
