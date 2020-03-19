extends Spatial

signal button_pressed
signal button_released

export var time = 0.1
var disabled setget set_disabled, get_disabled
export var disable = false
export var lightstate = 0

var mov_tween
var btn_standard_position = Vector3()
var btn_pressed_position = Vector3()

var button_pressed = false
var button_movement = false

var pushing_controllers = []

func set_disabled(new_value):
	if lightstate > 0:
		$Area2/OmniLight.visible = !new_value
	disabled = new_value

func get_disabled():
	return disabled

func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		print(pushing_controllers)
		if get_parent().get_parent().get_node("ARVROrigin").get_node("RightController") in pushing_controllers:
			_on_Area2_area_exited(get_parent().get_parent().get_node("ARVROrigin").get_node("RightController"))
		else:
			_on_Area2_area_entered(get_parent().get_parent().get_node("ARVROrigin").get_node("RightController"))
			print("enter")
	if Input.is_action_just_pressed("ui_left"):
		if get_parent().get_parent().get_node("ARVROrigin").get_node("LeftController") in pushing_controllers:
			_on_Area2_area_exited(get_parent().get_parent().get_node("ARVROrigin").get_node("LeftController"))
		else:
			_on_Area2_area_entered(get_parent().get_parent().get_node("ARVROrigin").get_node("LeftController"))

func _ready():
	disabled = disable
	mov_tween = get_node("MovementTween")
	btn_standard_position = $Area2.translation
	btn_pressed_position = Vector3(btn_standard_position.x, 0.025, btn_standard_position.z)
	if lightstate > 0:
		$Area2/OmniLight.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2_area_entered(area):
	if !button_movement and !(area in pushing_controllers):
		pushing_controllers.append(area)
		if !button_pressed:
			button_pressed = true
			mov_tween.interpolate_property($Area2, "translation", btn_standard_position, btn_pressed_position, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
			mov_tween.start()
			button_movement = true
			yield(mov_tween, "tween_completed")
			button_movement = false
			if lightstate == 1:
				$Area2/OmniLight.visible = true
			if !disabled:
				emit_signal("button_pressed")


func _on_Area2_area_exited(area):
	print("button area exited")
	if button_pressed and area in pushing_controllers and !button_movement:
		pushing_controllers.remove(pushing_controllers.find(area))
		if pushing_controllers.size() == 0:
			if lightstate == 1:
				$Area2/OmniLight.visible = false
			button_pressed = false
			mov_tween.interpolate_property($Area2, "translation", btn_pressed_position, btn_standard_position, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
			mov_tween.start()
			button_movement = true
			yield(mov_tween, "tween_completed")
			button_movement = false
			if !disabled:
				emit_signal("button_released")
