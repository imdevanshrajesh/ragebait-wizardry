extends CharacterBody2D

@export var speed: float = 900.0
@export var max_bounces: int = 4
@export var required_bounces: int = 1

var bounces_done: int = 0
var shooter_body: PhysicsBody2D = null

func _ready() -> void:
	add_to_group("bullets")
	velocity = Vector2.RIGHT.rotated(rotation) * speed

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var hit_object := collision.get_collider()
		if hit_object.is_in_group("player"):
			hit_object.get_parent().queue_free()
			queue_free()
			return
		if hit_object.is_in_group("enemy"):
			if bounces_done >= required_bounces:
				hit_object.queue_free()
			queue_free()
			return
		bounces_done += 1
		if is_instance_valid(shooter_body):
			remove_collision_exception_with(shooter_body)
		if bounces_done > max_bounces:
			queue_free()
		else:
			velocity = velocity.bounce(collision.get_normal())
			rotation = velocity.angle()
