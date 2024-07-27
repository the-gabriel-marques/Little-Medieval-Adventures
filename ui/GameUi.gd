extends CanvasLayer

onready var timer_label: Label = $TimerLabel
onready var meat_label: Label = $Panel2/MeatLabel

func _process(delta):
	#Update Labels
	timer_label.text = GameManager.time_elapse_string
	meat_label.text = str(GameManager.meat_counter)
