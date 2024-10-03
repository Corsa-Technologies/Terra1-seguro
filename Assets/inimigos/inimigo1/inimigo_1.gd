extends CharacterBody2D

@export var speed: float = 100.0
@export var gravity: float = 500.0
@export var patrol_tolerance: float = 10.0

var patrol_points: Array = []
var current_patrol_index: int = 0
var player_detected: bool = false
var player: Node2D = null  # Referência ao player detectado

func _ready():
	var patrol_parent = get_parent().get_node("patrulha1")
	for point in patrol_parent.get_children():
		if point is Marker2D:
			patrol_points.append(point)
	
	# Conectar sinais da Area2D (DetectionArea)
	$DetectionArea.connect("body_entered", Callable(self, "_on_DetectionArea_body_entered"))
	$DetectionArea.connect("body_exited", Callable(self, "_on_DetectionArea_body_exited"))

func _physics_process(delta):
	velocity.y += gravity * delta

	if player_detected and player:
		# Se o player foi detectado e a referência não é nula, o inimigo olha para ele
		look_at_player()
		$AnimatedSprite2D.play("shot1")  # Executa a animação de tiro
	else:
		# Comportamento de patrulha normal
		if patrol_points.size() > 0:
			var target_position = patrol_points[current_patrol_index].position
			var direction = (target_position - position).normalized()
			velocity.x = direction.x * speed

			if direction.x > 0:
				$AnimatedSprite2D.scale.x = 1
			elif direction.x < 0:
				$AnimatedSprite2D.scale.x = -1

			move_and_slide()

			if position.distance_to(target_position) < patrol_tolerance:
				current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")

# Função chamada quando o player entra na DetectionArea
func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player_detected = true
		player = body  # Guarda a referência ao player

# Função chamada quando o player sai da DetectionArea
func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player_detected = false
		player = null  # Limpa a referência ao player

# Função para fazer o inimigo olhar para o player
func look_at_player():
	# Verifica a posição do player e vira o inimigo
	var direction = (player.position - position).normalized()
	if direction.x > 0:
		$AnimatedSprite2D.scale.x = 1
	else:
		$AnimatedSprite2D.scale.x = -1
