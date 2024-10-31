extends Area2D

var entered=false

func _on_body_entered(body: PhysicsBody2D):
	# Verifique se o corpo que entrou é o Player
	if body.name == "Player":  # ou use 'is Player' se você tiver uma classe 'Player'
		entered = true
		Dialogic.start('timeline')
		get_viewport().set_input_as_handled()
		queue_free()
