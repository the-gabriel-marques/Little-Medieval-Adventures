extends Node

export var mob_spawner_path: NodePath
export var initial_spawn_rate: float = 60.0
export var spawn_rate_per_minute: float = 30.0
export var wave_duration: float = 20.0
export var break_intensity: float = 0.5

var time: float = 0.0
var mob_spawner: MobSpawner

func _ready():
	if mob_spawner_path:
		mob_spawner = get_node(mob_spawner_path) as MobSpawner
		if mob_spawner == null:
			print("Erro: MobSpawner não encontrado no caminho especificado")
		else:
			print("MobSpawner carregado com sucesso")
	else:
		print("Erro: Caminho do MobSpawner não especificado")

func _process(delta: float):
	#Ignorar/Game Over
	if GameManager.is_game_over: return
	
	#Incrementar temporizador
	time += delta
	
	# Dificuldade Linear: Linha verde
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * (time / 60)
	
	# Sistema de ondas: Linha rosa
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1.0)
	spawn_rate *= wave_factor
	
	# Aplica a dificuldade
	if mob_spawner:
		mob_spawner.mobs_per_minute = spawn_rate
	
func remap(value: float, min1: float, max1: float, min2: float, max2: float) -> float:
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1)
