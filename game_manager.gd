extends Node

signal game_over

var player: Player
var player_position: Vector2
var is_game_over: bool = false
var time_elapsed: float = 0.0
var time_elapse_string: String
var meat_counter: int = 0
var monsters_defeated_counter: int = 0

func _process(delta):
	time_elapsed += delta
	var time_elapsed_in_seconds: int = int(floor(time_elapsed))
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	time_elapse_string = "%02d:%02d" % [minutes, seconds]

func end_game():
	if is_game_over: return
	is_game_over = true
	emit_signal("game_over")

func reset():
	player = null
	player_position = Vector2.ZERO
	is_game_over = false
	
	time_elapsed = 0.0
	time_elapse_string = "00:00"
	meat_counter = 0
	monsters_defeated_counter = 0
	
	# Desconectar todas as conexões do sinal game_over
	for connection in get_signal_connection_list("game_over"):
		if connection["target"] == self:
			disconnect("game_over", self, connection["method"])
