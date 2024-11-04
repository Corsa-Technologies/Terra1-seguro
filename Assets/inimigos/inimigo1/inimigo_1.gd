extends CharacterBody2D

@export var speed: float = 150.0
@export var gravity: float = 500.0
@export var patrol_tolerance: float = 10.0
@export var health: int = 100  # Adiciona uma variável de saúde ao inimigo

var patrol_points: Array = []
var current_patrol_index: int = 0

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

	# Lógica de patrulha entre os pontos globais dos Markers2D
	if patrol_points.size() > 0:
		var target_position = patrol_points[current_patrol_index]  # Usa a posição global
		var direction = (target_position - global_position).normalized()  # Compara com a posição global

		velocity.x = direction.x * speed

		# Atualiza a rotação do sprite para refletir a direção
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = true  # Olha para a direita
		elif direction.x < 0:
			$AnimatedSprite2D.flip_h = false  # Olha para a esquerda

		move_and_slide()

		# Verifica se o inimigo chegou ao ponto de patrulha
		if global_position.distance_to(target_position) < patrol_tolerance:
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

# Função para receber dano
func take_damage(amount: int):
	health -= amount  # Subtrai o dano da saúde do inimigo
	if health <= 0:
		die()  # Chama a função de morte se a saúde for menor ou igual a 0

# Função de morte
func die():
	queue_free()  # Remove o inimigo da cena
