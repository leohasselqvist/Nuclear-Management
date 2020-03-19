extends Spatial

var value
var controller = null
var lever

var display

func _ready():
	lever = get_node("Lever")


# warning-ignore:unused_argument
func _process(delta):
	
	value = (lever.rotation_degrees.x + 90) / 180
	print("lever value: " + str(value))
	if controller != null:
	#and controller.trigger_pressed:
		print("Lever: CONTROLLER FOUND AND TRIGGER PRESSED")
		lever.look_at(Vector3(controller.get_translation().x,controller.get_translation().y,get_translation().z), Vector3(0,1,0))
		#lever.rotation_degrees.x = 0
		#lever.rotation_degrees.y = 0
		if lever.rotation_degrees.z >= 90:
			lever.rotation_degrees.z = 90
		if lever.rotation_degrees.z <= -90:
			lever.rotation_degrees.z = -90

func _on_Lever_area_entered(area):
	
	print("Lever: BODY ENTERED: " + str(area))
	if area is ARVRController:
		controller = area


func _on_ActionArea_area_exited(area):
	print("Lever: BODY EXITED: " + str(area))
	print("Lever: CONTROLLER SET TO NULL")
	controller = null
