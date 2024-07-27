class_name Enemy
extends Node2D

#life
export var health: int = 10
export var death_prefab: PackedScene
export (PackedScene) var damage_digit_prefab = preload("res://enemies/misc/damage_digit.tscn")

onready var damage_digit_marker = $DamageDigitMarker

#drops
export var drop_chance: float = 0.1
export (Array, PackedScene) var drop_items
export (Array, float) var drop_chances

func damage(amount: int) -> void:
	health -= amount
	print("Inimigo recebeu dano de ", amount, ". A vida total é de ", health)
	
	# Piscar node
	modulate = Color(1, 0, 0)  # Vermelho
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", Color(1, 0, 0), Color(1, 1, 1), 0.3, Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.start()
	
	# Criar DamageDigit
	if damage_digit_prefab:
		var damage_digit = damage_digit_prefab.instance()
		if damage_digit.has_method("set_value"):
			damage_digit.set_value(amount)
		elif damage_digit.has_meta("value"):
			damage_digit.set("value", amount)
		if damage_digit_marker:
			damage_digit.global_position = damage_digit_marker.global_position
		else:
			damage_digit.global_position = global_position
		get_parent().add_child(damage_digit)
	else:
		print("Erro: damage_digit_prefab não foi carregado corretamente")
	
	# Processar morte
	if health <= 0:
		die()

func die() -> void:
	#caveira
	if death_prefab:
		var death_object = death_prefab.instance()
		death_object.position = position
		get_parent().add_child(death_object)
	
	#drop
	if randf() <= drop_chance:
		drop_item()
		
	#Incrementar contador
	GameManager.monsters_defeated_counter += 1
	
	#deletar node
	queue_free()
	
func drop_item():
	var drop = get_random_drop_item().instance()
	drop.position = position
	get_parent().add_child(drop)
	
func get_random_drop_item() -> PackedScene:
	#listas com 1 item
	if drop_items.size() == 1:
		return drop_items[0]
	
	#calcular a chance máxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
		
	#jogar dado
	var random_value = randf() * max_chance
	
	#girar a roleta
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
		
	return drop_items[0]
