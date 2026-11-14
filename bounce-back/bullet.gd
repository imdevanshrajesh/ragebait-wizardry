extends CharacterBody2D

@export var speed: float = 900.0
@export var max_bounces: int = 5
var bounces_left: int = max_bounces
func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(rotation) * speed
func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var hit_object := collision.get_collider()
		if hit_object.is_in_group("enemy"):
			hit_object.queue_free() 
			queue_free()            
			return
		bounces_left -= 1
		if bounces_left < 0:
			queue_free() 
		else:
			velocity = velocity.bounce(collision.get_normal())
			rotation = velocity.angle()
