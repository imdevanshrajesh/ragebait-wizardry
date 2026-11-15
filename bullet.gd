extends CharacterBody2D

@export var speed: float = 1500.0
@export var max_bounces: int = 5
@export var required_bounces: int = 1

var bounces_done: int = 0
var shooter_body: PhysicsBody2D = null
var last_wall: Object = null

func _ready() -> void:
	add_to_group("bullets")
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 120.0
	$CollisionShape2D.shape = circle
	velocity = Vector2.RIGHT.rotated(rotation) * speed

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var hit_object: Object = collision.get_collider()
		if hit_object is Node and (hit_object as Node).is_in_group("player"):
			var player_node: Node = (hit_object as Node).get_parent()
			if player_node != null and player_node.has_method("die"):
				player_node.die()
			queue_free()
			return
		if hit_object is Node2D and (hit_object as Node2D).is_in_group("enemy"):
			if bounces_done >= required_bounces:
				kill_enemy(hit_object as Node2D)
			queue_free()
			return
		var normal: Vector2 = collision.get_normal()
		global_position += normal * 6.0
		velocity = velocity.bounce(normal)
		rotation = velocity.angle()
		if hit_object != last_wall:
			last_wall = hit_object
			bounces_done += 1
		if is_instance_valid(shooter_body):
			remove_collision_exception_with(shooter_body)
		if bounces_done > max_bounces:
			queue_free()

func kill_enemy(enemy_node: Node2D) -> void:
	enemy_node.remove_from_group("enemy")
	var enemy_col: CollisionShape2D = enemy_node.get_node_or_null("CollisionShape2D")
	if enemy_col != null:
		enemy_col.set_deferred("disabled", true)
	var enemy_sprite: Sprite2D = enemy_node.get_node_or_null("Sprite2D")
	if enemy_sprite != null:
		var tween: Tween = enemy_node.create_tween().set_parallel(true)
		tween.tween_property(enemy_sprite, "rotation", deg_to_rad(90.0), 0.25)
		tween.tween_property(enemy_sprite, "position:y", enemy_sprite.position.y + 18.0, 0.25)
	enemy_node.call_deferred("reparent", get_tree().current_scene)
