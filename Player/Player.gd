class_name Player
extends KinematicBody2D

#movement
export var speed: float = 300.0
#sword
export var sword_damage: int = 2
#ritual
export var ritual_damage: int = 1
export var ritual_interval: float = 30
export var ritual_scene: PackedScene
#life
export var health: int = 100
export var death_prefab: PackedScene
export var max_health: int = 100

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sword_area: Area2D = $SwordArea
onready var hitbox_area: Area2D = $HitBoxArea
onready var health_progress_bar : ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0,0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

signal meat_collected(value)

func _ready():
	GameManager.player = self
	connect("meat_collected", GameManager, "_on_meat_collected")

func _process(delta: float):
	GameManager.player_position = position
	
	read_input()
	
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()

	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
		
	#Processar dano
	update_hitbox_detection(delta)
	
	#ritual
	update_ritual(delta)
	
	#Atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta: float):
	velocity = input_vector * speed
	move_and_slide(velocity)

func update_attack_cooldown(delta: float):
	if is_attacking:
		attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		is_attacking = false
		is_running = false
		animation_player.play("idle")

	if is_attacking:
		velocity *= 0.25

	velocity = lerp(velocity, input_vector * speed, 0.05)
	move_and_slide(velocity)
	
func update_ritual(delta: float):
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	#criar o ritual
	var ritual = ritual_scene.instance()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	pass

func read_input():
		input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
		var deadzone = 0.15
		if abs(input_vector.x) < 0.15:
			input_vector.x = 0.0
		if abs(input_vector.y) < 0.15:
			input_vector.y = 0.0
			
		was_running = is_running
		is_running = not input_vector.is_equal_approx(Vector2.ZERO)

func play_run_idle_animation():
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite():
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func attack():
	if is_attacking:
		return
	is_attacking = true
	
	attack_cooldown = 1.0  # Ajuste o tempo de cooldown conforme necessário
	
	animation_player.play("attack_side_1")
	
	
func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy =  body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)
				
func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	# Frequência
	hitbox_cooldown = 0.5
	
	# Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount, ". A vida total é de ", health, "/", max_health)
	
	# Piscar node
	modulate = Color.red
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.white, 0.3)
	
	# Processar morte
	if health <= 0:
		die()


func die() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instance()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Player morreu!")
	queue_free()
	
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health)
	return health
