extends CharacterBody2D

var SPEED = 300.0
const JUMP_VELOCITY = -350.0
var canjump := true
var is_shooting = false # Variável para controlar se o personagem está atirando
@onready var coyote_timer = $CoyoteTimer as Timer
@onready var animated_sprite = $AnimatedSprite2D # Referência ao AnimatedSprite2D
@export var buffer_time: float = 0.15
@export var coyote_time: float = 0.1
var jump_buffered = false
var buffer_timer = 0.0

func _ready():
	coyote_timer.wait_time = coyote_time

func pular():
	velocity.y = JUMP_VELOCITY
	# A animação de pulo agora será tocada diretamente na _physics_process quando o personagem estiver no ar

func _physics_process(delta):
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Suporta o "jump buffer".
	if Input.is_action_just_pressed("ui_up") and not is_shooting:
		jump_buffered = true
		buffer_timer = buffer_time

	# Diminui o tempo do jump buffer.
	if jump_buffered:
		buffer_timer -= delta
		if buffer_timer <= 0.0:
			jump_buffered = false

	# Suporta o pulo, incluindo o coyote time.
	if jump_buffered and canjump and not is_shooting:
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

	# Lógica de movimentação, somente se não estiver atirando.
	if not is_shooting:
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

func _input(event : InputEvent):
	if event.is_action_pressed("ui_down") and is_on_floor():
		position.y += 1

	# Verifica se o botão "tiro" foi pressionado e o personagem não está atirando
	if event.is_action_pressed("tiro") and not is_shooting:
		is_shooting = true
		velocity.x = 0 # Para o personagem de se mover enquanto atira
		animated_sprite.play("tiro")
		# Conecta o sinal de "animation_finished" com a função que será chamada quando a animação terminar
		animated_sprite.connect("animation_finished", Callable(self, "_on_shoot_animation_finished"))

func _on_shoot_animation_finished():
	# Quando a animação de tiro termina, voltamos ao estado normal
	is_shooting = false
	animated_sprite.disconnect("animation_finished", Callable(self, "_on_shoot_animation_finished"))

func _on_coyote_timer_timeout() -> void:
	canjump = false
