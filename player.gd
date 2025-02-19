extends Area2D

signal hit

@export var max_lives = 3
var lives
@export var speed = 400
var screen_size
@onready var hud = get_node("/root/Main/HUD")
@onready var livesLabel = get_node("/root/Main/HUD/LivesLabel")
@onready var livesIcon = get_node("/root/Main/HUD/LivesIcon")



func _ready():
	screen_size = get_viewport_rect().size
	lives = max_lives
	livesLabel.hide()
	livesIcon.hide()
	hide()


func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0


func start(pos):
	position = pos
	rotation = 0
	hud.update_lives(lives)
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body):
	lives -= 1
	hud.update_lives(lives)
	if lives <= 0:
		hide()
		lives = max_lives
		hit.emit()
		$CollisionShape2D.set_deferred(&"disabled", true)
	else:
		start(Vector2(screen_size.x / 2, screen_size.y / 2))
		
