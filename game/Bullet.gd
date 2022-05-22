extends Sprite

var speed = 500
var dir = Vector2(1,0)

func _ready():
	scale = Vector2(.1,.1)

func _physics_process(delta):
	position += speed * delta * dir
