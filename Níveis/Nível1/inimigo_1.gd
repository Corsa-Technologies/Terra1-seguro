extends CharacterBody2D

@export var speed: float = 100.0
@export var gravity: float = 500.0
@export var patrol_tolerance: float = 10.0
@export var projectile_scene: PackedScene  # Referência à cena do projétil
@export var shoot_delay: float = 1.0  # Intervalo de disparo em segundos

var patrol_points: Array = []
var current_patrol_index: int = 0
var player_detected: bool = false
var player: Node2D = null
var can_shoot: bool = true  # Controle para evitar múltiplos disparos

func _ready():
	# Verifica se o nó 'patrulha1' existe como filho do inimigo
	if has_node("patrulha1"):
		var patrol_parent = $patrulha1
		for point in patrol_parent.get_children():
			if point is Marker2D:
				patrol_points.append(point.global_position)  # Usa a posição global dos Markers2D
	else:
		$AnimatedSprite2D.play('idle')
	
	# Conectar sinais da Area2D (DetectionArea)
	$DetectionArea.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	$DetectionArea.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))

func _physics_process(delta):
	velocity.y += gravity * delta

	if player_detected and player:
		look_at_player()
		$AnimatedSprite2D.play("shot1")  # Executa a animação de tiro
		if can_shoot:
			shoot_projectile()  # Dispara o projétil
			can_shoot = false  # Desativa o disparo até o próximo intervalo
			await get_tree().create_timer(shoot_delay).timeout  # Espera o tempo de disparo
			can_shoot = true  # Reativa o disparo após o intervalo
	else:
		# Lógica de patrulha entre os pontos globais dos Markers2D
		if patrol_points.size() > 0:
			var target_position = patrol_points[current_patrol_index]  # Usa a posição global
			var direction = (target_position - global_position).normalized()  # Compara com a posição global

			velocity.x = direction.x * speed

			# Atualiza a escala do sprite para refletir a direção
			if direction.x > 0:
				$AnimatedSprite2D.scale.x = 1
			elif direction.x < 0:
				$AnimatedSprite2D.scale.x = -1

			move_and_slide()

			# Verifica se o inimigo chegou ao ponto de patrulha
			if global_position.distance_to(target_position) < patrol_tolerance:
				current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")

# Função chamada quando o player entra na DetectionArea
func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player_detected = true
		player = body

# Função chamada quando o player sai da DetectionArea
func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player_detected = false
		player = null

# Função para fazer o inimigo olhar para o player
func look_at_player():
	var direction = (player.global_position - global_position).normalized()
	if direction.x > 0:
		$AnimatedSprite2D.scale.x = 1
	else:
		$AnimatedSprite2D.scale.x = -1

# Função para instanciar e disparar o projétil na direção do player
func shoot_projectile():
	# Verifica se a cena do projétil foi atribuída
	if projectile_scene == null:
		return
	
	# Instanciar a cena do projétil
	var projectile = projectile_scene.instantiate() as CharacterBody2D
	
	# Certifique-se que o projétil foi instanciado corretamente
	if projectile == null:
		return

	# Define a posição inicial do projétil, um pouco à frente do inimigo
	projectile.global_position = global_position + Vector2(0 * $AnimatedSprite2D.scale.x, 0)

	# Define a direção do projétil como a direção do player
	var direction = (player.global_position - projectile.global_position).normalized()
	projectile.direction = direction  # Define a direção diretamente no projétil
	
	# Adiciona o projétil à cena
	get_parent().add_child(projectile)
