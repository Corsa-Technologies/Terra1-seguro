extends CharacterBody2D

@export var speed: float = 150.0
@export var gravity: float = 500.0
@export var patrol_tolerance: float = 10.0
@export var health: int = 100  # Adiciona uma variável de saúde ao inimigo
@export var damage: int = 20

var patrol_points: Array = []
var current_patrol_index: int = 0
var player_target: Node = null  # Armazena o jogador detectado

func _ready():
	# Verifica se o nó 'patrulha1' existe como filho do inimigo
	if has_node("patrulha1"):
		var patrol_parent = $patrulha1
		for point in patrol_parent.get_children():
			if point is Marker2D:
				patrol_points.append(point.global_position)  # Usa a posição global dos Markers2D
	else:
		$AnimatedSprite2D.play('idle')

func _physics_process(delta):
	velocity.y += gravity * delta

	if player_target:
		# Movimento em direção ao jogador
		var direction = (player_target.global_position - global_position).normalized()
		velocity.x = direction.x * speed

		# Atualiza a rotação do sprite para refletir a direção
		$AnimatedSprite2D.flip_h = direction.x > 0

		move_and_slide()
		$AnimatedSprite2D.play("walk")
	else:
		# Lógica de patrulha entre os pontos globais dos Markers2D
		if patrol_points.size() > 0:
			var target_position = patrol_points[current_patrol_index]
			var direction = (target_position - global_position).normalized()
			velocity.x = direction.x * speed

			# Atualiza a rotação do sprite para refletir a direção
			$AnimatedSprite2D.flip_h = direction.x > 0

			move_and_slide()

			# Verifica se o inimigo chegou ao ponto de patrulha
			if global_position.distance_to(target_position) < patrol_tolerance:
				current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	# Verifica se o corpo que entrou na DetectionArea é o jogador
	if body.name == ("Player"):
		player_target = body  # Define o jogador como alvo
		print('o player agora é o alvo')


func _on_detection_area_body_exited(body):
	# Verifica se o corpo que entrou na DetectionArea é o jogador
	if body.name == ("Player"):
		player_target = null  # remove o jogador de alvo
		print('o player n é mais o alvo')

func _on_hitbox_body_entered(body):
	# Verifica se o corpo que entrou na área é o jogador
	if body.name == ("Player"):
		# Chama a função `take_damage` do jogador
		body.take_damage(damage)

# Função para receber dano
func take_damage(amount: int):
	health -= amount  # Subtrai o dano da saúde do inimigo
	if health <= 0:
		die()  # Chama a função de morte se a saúde for menor ou igual a 0

# Função de morte
func die():
	queue_free()  # Remove o inimigo da cena
