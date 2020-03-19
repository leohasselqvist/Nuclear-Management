extends Spatial

var brokenlight_scene = preload("res://scenes/BrokenLight.tscn")
var lightbody
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	lightbody = get_node("Light Body")

func _process(delta):
	if Input.is_action_just_pressed("ext_debug"):
		break_obj()

func break_obj():	
	var brokenlight = brokenlight_scene.instance()
	brokenlight.translation = lightbody.global_transform.origin
	get_parent().add_child(brokenlight)
	queue_free()

func _on_Light_Body_body_entered(body):
	if body is RigidBody:
		break_obj()
