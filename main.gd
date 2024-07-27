extends Node

export var get_node_path: NodePath
export var game_over_ui_template: PackedScene

var game_ui

func _ready():
	if get_node_path:
		game_ui = get_node(get_node_path)
	
	# Conectar o sinal "game_over" do GameManager ao método "trigger_game_over"
	if GameManager.has_signal("game_over"):
		GameManager.connect("game_over", self, "trigger_game_over")

func trigger_game_over():
	# Deletar o GameUI
	if game_ui:
		game_ui.queue_free()
		game_ui = null

	# Criar o Game Over UI
	var game_over_ui = game_over_ui_template.instance()
	add_child(game_over_ui)
