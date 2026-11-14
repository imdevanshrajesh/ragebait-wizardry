extends Node2D

const BULLET_SCENE := preload("res://bullet.tscn")

@export var ammo: int = 5
@export var bullet_speed: float = 900.0
@export var max_bounces: int = 4
@export var required_bounces: int = 1
@export var laser_length: float = 120.0

@onready var player_body: StaticBody2D = $StaticBody2D
@onready var player_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var gun_pivot: Node2D = $StaticBody2D/GunPivot
@onready var gun_sprite: Sprite2D = $StaticBody2D/GunPivot/GunSprite
@onready var fire_point: Marker2D = $StaticBody2D/GunPivot/GunSprite/FirePoint

var laser_line: Line2D

func _ready() -> void:
	player_collision.disabled = false
	laser_line = Line2D.new()
	laser_line.width = 4.0
	laser_line.default_color = Color(1.0, 0.15, 0.15, 0.75)
	get_tree().current_scene.call_deferred("add_child", laser_line)

func _exit_tree() -> void:
	if is_instance_valid(laser_line):
		laser_line.queue_free()

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	gun_pivot.look_at(mouse_pos)
	gun_sprite.flip_v = mouse_pos.x < gun_pivot.global_position.x
	update_laser_sight()
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		shoot()

func update_laser_sight() -> void:
	if not is_instance_valid(laser_line):
		return
	if laser_length <= 0.0:
		laser_line.points = []
		return
	var start_pos := fire_point.global_position
	var dir := Vector2.RIGHT.rotated(gun_pivot.global_rotation)
	laser_line.points = [start_pos, start_pos + dir * laser_length]

func shoot() -> void:
	ammo -= 1
	var bullet := BULLET_SCENE.instantiate()
	bullet.global_position = fire_point.global_position
	bullet.global_rotation = gun_pivot.global_rotation
	bullet.speed = bullet_speed
	bullet.max_bounces = max_bounces
	bullet.required_bounces = required_bounces
	bullet.shooter_body = player_body
	bullet.add_collision_exception_with(player_body)
	get_tree().current_scene.add_child(bullet)
