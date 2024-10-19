extends Node2D

# Função chamada quando um corpo entra na área
func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player":
		body.heal_count += 1  # Aumenta o contador de cura do jogador
		body.update_heal_display()  # Atualiza a exibição da cura, se você tiver uma função
		queue_free()  # Remove a seringa da cena
