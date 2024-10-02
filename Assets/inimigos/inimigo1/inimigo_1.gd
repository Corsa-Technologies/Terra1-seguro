extends CharacterBody2D

# Variáveis exportadas para configuração fácil no editor
@export var speed: float = 100.0        # Velocidade do inimigo
@export var gravity: float = 500.0      # Força da gravidade aplicada ao inimigo
@export var patrol_tolerance: float = 10.0  # Tolerância para considerar que chegou ao ponto de patrulha

var patrol_points: Array = []           # Lista de pontos de patrulha
var current_patrol_index: int = 0       # Índice atual do ponto de patrulha

func _ready():
	# Acesse o nó que contém os pontos de patrulha (assumindo que você tem um nó "patrulha1" com pontos filhos)
	var patrol_parent = get_parent().get_node("patrulha1")
	
	# Adiciona todos os filhos do nó de patrulha à lista de pontos
	for point in patrol_parent.get_children():
		if point is Marker2D:  # Verifica se o nó é um ponto de patrulha (Marker2D)
			patrol_points.append(point)

func _physics_process(delta):
	# Aplica gravidade ao inimigo
	velocity.y += gravity * delta  # Gravidade puxa o inimigo para baixo
	
	if patrol_points.size() > 0:
		var target_position = patrol_points[current_patrol_index].position  # Ponto de patrulha atual
		var direction = (target_position - position).normalized()           # Direção até o próximo ponto
		
		# Atualiza a velocidade horizontal do inimigo na direção do próximo ponto de patrulha
		velocity.x = direction.x * speed

		# Verifica se o inimigo está indo para a esquerda ou para a direita e vira o sprite
		if direction.x > 0:
			$AnimatedSprite2D.scale.x = 1  # Virado para a direita (escala normal)
		elif direction.x < 0:
			$AnimatedSprite2D.scale.x = -1  # Virado para a esquerda (espelhado horizontalmente)

		# Move o inimigo com a função move_and_slide(), que aplica física automaticamente
		move_and_slide()

		# Verifica se o inimigo chegou suficientemente perto do ponto de patrulha
		if position.distance_to(target_position) < patrol_tolerance:
			# Atualiza para o próximo ponto de patrulha (ciclo contínuo)
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

		# Anima o inimigo
		$AnimatedSprite2D.play("walk")  # Certifique-se que você tem uma animação "walk"
	else:
		# Caso não haja pontos de patrulha, fica em idle
		$AnimatedSprite2D.play("idle")
