extends Area2D




func _on_body_entered(body: CharacterBody2D):
	get_tree().reload_current_scene()
	transicaotela
