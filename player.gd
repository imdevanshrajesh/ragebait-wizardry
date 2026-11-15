extends Node2D

const BULLET_SCENE := preload("res://bullet.tscn")
@export var sound_played: bool = false
@export var ammo: int = 10
@export var bullet_speed: float = 900.0
@export var max_bounces: int = 4
@export var required_bounces: int = 1
@export var laser_length: float = 120.0

@onready var player_body: StaticBody2D = $StaticBody2D
@onready var player_sprite: Sprite2D = $StaticBody2D/Sprite2D
@onready var player_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var gun_pivot: Node2D = $StaticBody2D/GunPivot
@onready var gun_sprite: Sprite2D = $StaticBody2D/GunPivot/GunSprite
@onready var fire_point: Marker2D = $StaticBody2D/GunPivot/GunSprite/FirePoint

var laser_line: Line2D
var base_gun_y: float = 24.0
var base_fire_y: float = -90.96277
var last_bullet: CharacterBody2D = null
var is_dead: bool = false

func _ready() -> void:
	player_collision.disabled = false
	base_gun_y = abs(gun_sprite.position.y)
	base_fire_y = -abs(fire_point.position.y)
	var temp_bullet := BULLET_SCENE.instantiate()
	required_bounces = maxi(required_bounces, temp_bullet.required_bounces)
	temp_bullet.free()
	laser_line = Line2D.new()
	laser_line.width = 4.0
	laser_line.default_color = Color(1.0, 0.15, 0.15, 0.75)
	get_tree().current_scene.call_deferred("add_child", laser_line)

func _exit_tree() -> void:
	if is_instance_valid(laser_line):
		laser_line.queue_free()

func _process(_delta: float) -> void:
	if is_dead:
		return
	var mouse_pos := get_global_mouse_position()
	var aiming_left := mouse_pos.x < player_sprite.global_position.x
	player_sprite.flip_h = aiming_left
	gun_sprite.flip_v = aiming_left
	if aiming_left:
		gun_sprite.position.y = -base_gun_y
		fire_point.position.y = -base_fire_y
	else:
		gun_sprite.position.y = base_gun_y
		fire_point.position.y = base_fire_y
	gun_pivot.look_at(mouse_pos)
	update_laser_sight()
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		shoot()

func die() -> void:
	if sound_played == false:
			var sfx = AudioStreamPlayer.new()
			sfx.stream = load("res://Assets/Audio/death.mp3")
			add_child(sfx)
			sfx.play()
	if is_dead:
		return
	is_dead = true
	player_collision.set_deferred("disabled", true)
	if is_instance_valid(laser_line):
		laser_line.points = []
	var fall_angle := deg_to_rad(90.0)
	if player_sprite.flip_h:
		fall_angle = deg_to_rad(-90.0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(player_sprite, "rotation", fall_angle, 0.25)
	tween.tween_property(player_sprite, "position:y", player_sprite.position.y + 80.0, 0.25)
	tween.tween_property(gun_pivot, "rotation", fall_angle, 0.25)
	tween.tween_property(gun_pivot, "position:y", player_sprite.position.y + 80.0, 0.25)

func get_aim_direction() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	var barrel_pos := fire_point.global_position
	if mouse_pos.distance_to(gun_pivot.global_position) > 90.0:
		return (mouse_pos - barrel_pos).normalized()
	return Vector2.RIGHT.rotated(gun_pivot.global_rotation)

func update_laser_sight() -> void:
	if not is_instance_valid(laser_line):
		return
	if laser_length <= 0.0:
		laser_line.points = []
		return
	var start_pos := fire_point.global_position
	var dir := get_aim_direction()
	laser_line.points = [start_pos, start_pos + dir * laser_length]

func shoot() -> void:
	if sound_played == false:
			var sfx = AudioStreamPlayer.new()
			sfx.stream = load("res://Assets/Audio/gun_shot.mp3")
			add_child(sfx)
			sfx.play()
	ammo -= 1
	var bullet := BULLET_SCENE.instantiate()
	var dir := get_aim_direction()
	bullet.global_position = fire_point.global_position
	bullet.global_rotation = dir.angle()
	bullet.speed = bullet_speed
	bullet.max_bounces = max_bounces
	bullet.required_bounces = maxi(required_bounces, bullet.required_bounces)
	bullet.shooter_body = player_body
	bullet.add_collision_exception_with(player_body)
	last_bullet = bullet
	get_tree().current_scene.add_child(bullet)
