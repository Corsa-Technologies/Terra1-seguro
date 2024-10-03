extends CharacterBody2D 

@export var SPEED = 600

var direction: Vector2  # A direção do projétil

func _ready():
	# Define a rotação do projétil para a direção de movimento
	rotation = direction.angle()  # Ajusta a rotação para a direção

	# Inicia a movimentação do projétil
	await get_tree().create_timer(3).timeout  # Espera 5 segundos
	queue_free()  # Remove o projétil da cena

func _physics_process(delta):
	velocity = direction * SPEED  # Move o projétil na direção especificada
	move_and_slide()  # Aplica a movimentação
