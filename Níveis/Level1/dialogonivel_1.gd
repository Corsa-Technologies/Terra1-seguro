extends Area2D


func _on_body_entered(body: CharacterBody2D):
	if body.name == "Player":
		Dialogic.start('Dialogo1')
		queue_free()
