extends Node

export var speed = 1.0

var velocity: Vector2 = Vector2.ZERO
var enemy: Enemy
var sprite: AnimatedSprite

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite")

func _physics_process(delta: float):
	if GameManager.is_game_over: return
	
	#Calcula a direção
	var player_position = GameManager.player_position
	var diference = player_position - enemy.position
	var input_vector = diference.normalized()
	
	#Anda
	velocity = input_vector * speed * 100.0
	enemy.move_and_slide(velocity)
	
	# Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

