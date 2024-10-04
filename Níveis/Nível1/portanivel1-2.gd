extends Area2D

var entered = false

func _on_body_entered(body: PhysicsBody2D):
	# Verifique se o corpo que entrou é o Player
	if body.name == "Player":  # ou use 'is Player' se você tiver uma classe 'Player'
		entered = true

func _on_body_exited(body):
	# Verifique se o corpo que saiu é o Player
	if body.name == "Player":  # ou use 'is Player' se você tiver uma classe 'Player'
		entered = false

func _process(delta):
	if entered:
		transicaotela.transition()
		get_tree().change_scene_to_file("res://Níveis/Nível2/Nível 2.tscn")
