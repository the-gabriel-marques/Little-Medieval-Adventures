extends Node2D

export var regeneration_amount: int = 10

func _ready():
	$Area2D.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneration_amount)
		player.emit_signal("meat_collected", regeneration_amount)
		queue_free()
