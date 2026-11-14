extends Node2D

const BULLET_SCENE := preload("res://bullet.tscn")

@onready var gun_pivot: Node2D = $StaticBody2D/GunPivot
@onready var fire_point: Marker2D = $StaticBody2D/GunPivot/GunSprite/FirePoint
func _process(_delta: float) -> void:
	gun_pivot.look_at(get_global_mouse_position())
	if get_global_mouse_position().x < gun_pivot.global_position.x:
		gun_pivot.scale.y = -abs(gun_pivot.scale.y)
	else:
		gun_pivot.scale.y = abs(gun_pivot.scale.y)
	if Input.is_action_just_pressed("shoot"):
		shoot()
func shoot() -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.global_position = fire_point.global_position
	bullet.global_rotation = gun_pivot.global_rotation
	get_tree().current_scene.add_child(bullet)
