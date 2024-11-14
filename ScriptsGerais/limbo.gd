extends Area2D




func _on_body_entered(body: CharacterBody2D):
	if body.name == ("Player"):
		body.take_damage(100)
