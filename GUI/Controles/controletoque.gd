extends CanvasLayer

@onready var esquerda = $Control/Esquerda
@onready var direita = $Control/Direita
@onready var pulo = $Control/Pulo
@onready var descer = $Control/Descer
@onready var tiro = $Control/Tiro
@onready var ataque = $Control/Ataque
@onready var health_text = $Control/HealthText

# Atualiza o texto da vida
func update_health_text(current_health: int, max_health: int) -> void:
	health_text.text = "Vida: " + str(current_health) + " / " + str(max_health)

func _on_esquerda_pressed():
	esquerda.modulate.a = 0.5

func _on_esquerda_released():
	esquerda.modulate.a = 1.0

func _on_direita_pressed():
	direita.modulate.a = 0.5

func _on_direita_released():
	direita.modulate.a = 1.0

func _on_pulo_pressed():
	pulo.modulate.a = 0.5

func _on_pulo_released():
	pulo.modulate.a = 1.0

func _on_descer_pressed():
	descer.modulate.a = 0.5

func _on_descer_released():
	descer.modulate.a = 1.0

func _on_tiro_pressed():
	tiro.modulate.a = 0.5

func _on_tiro_released():
	tiro.modulate.a = 1.0

func _on_ataque_pressed():
	ataque.modulate.a = 0.5

func _on_ataque_released():
	ataque.modulate.a = 1.0


func _on_dash_pressed() -> void:
	print('apertado')
