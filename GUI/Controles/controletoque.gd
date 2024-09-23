extends CanvasLayer
@onready var esquerda = $Esquerda
@onready var direita = $Direita
@onready var pulo = $Pulo



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
