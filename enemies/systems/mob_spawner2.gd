class_name MobSpawner
extends Node2D

export (Array, PackedScene) var creatures

onready var path_follow_2d: PathFollow2D = $"Path2D/PathFollow2D"

var cooldown: float = 0.0
var rng = RandomNumberGenerator.new()
var mobs_per_minute: float = 60.0

func _process(delta: float):
	if GameManager.is_game_over: return
	
	# Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0:
		return
	
	# Frequência (monstros por minuto)
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar se o ponto é válido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	
	var parameters = Physics2DShapeQueryParameters.new()
	parameters.transform = Transform2D(0, point)
	parameters.collision_layer = 0b1001
	parameters.shape_rid = Physics2DServer.circle_shape_create()
	Physics2DServer.shape_set_data(parameters.shape_rid, 5)  # Define o raio do círculo para 5 unidades
	
	var result = world_state.intersect_point(point)
	
	# Verificar se o ponto está livre
	if result.size() > 0:
		print("Colisão detectada no ponto: ", point)
		return
	
	# Instanciar uma criatura aleatória
	var index = rng.randi_range(0, creatures.size() - 1)  # Use randi_range em vez de randf_range para índices
	var creature_scene = creatures[index]
	var creature = creature_scene.instance()
	creature.global_position = point
	get_parent().add_child(creature)

func get_point() -> Vector2:
	path_follow_2d.unit_offset = rng.randf()  # Use rng.randf() para randomização
	return path_follow_2d.position
