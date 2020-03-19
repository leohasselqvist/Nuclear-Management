extends ARVRController

signal controller_activated(controller)

var ovr_render_model
var components = Array()
var ws = 0

var controller_velocity = Vector3(0,0,0)
var prior_controller_position = Vector3(0,0,0)
var prior_controller_velocities = []
var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}

var hand_mesh
var grab_pos
var grab_area

var trigger_pressed

var teleporting = false
var temp_laser_disable = false

func _ready():
	# instance our render model object
	ovr_render_model = preload("res://addons/godot-openvr/OpenVRRenderModel.gdns").new()
	grab_area = get_node("PickupArea")
	grab_pos = get_node("GrabPos")
	hand_mesh = get_node("Controller_mesh")
	
	connect("button_pressed", self, "_button_pressed")
	connect("button_release", self, "_button_released")
	
	#ui.visible = false
	
	 #hide to begin with
	visible = false

func apply_world_scale():
	var new_ws = ARVRServer.world_scale
	if (ws != new_ws):
		ws = new_ws
		$Controller_mesh.scale = Vector3(ws, ws, ws)

func load_controller_mesh(controller_name):
	if ovr_render_model.load_model(controller_name.substr(0, controller_name.length()-2)):
		return ovr_render_model
	
	if ovr_render_model.load_model("generic_controller"):
		return ovr_render_model
	
	return Mesh.new()

func _process(delta):
	if !get_is_active():
		visible = false
		return
	
	# always set our world scale, user may end up changing this
	apply_world_scale()
	
	if visible:
		return
	
	# became active? lets handle it...
	var controller_name = get_controller_name()
	print("Controller " + controller_name + " became active")
			
	# attempt to load a mesh for this
	$Controller_mesh.mesh = load_controller_mesh(controller_name)
			
	# make it visible
	visible = true
	emit_signal("controller_activated", self)

func _physics_process(delta):
	
	if get_is_active():
		_physics_process_update_controller_velocity(delta)
		
	
	if held_object != null:
		var held_scale = held_object.scale
		held_object.global_transform = grab_pos.global_transform
		held_object.scale = held_scale
	
	
	
#	if Input.is_action_just_pressed("ext_debug") and !ui_tween.is_active():
#		_button_pressed(1)
		

func _physics_process_update_controller_velocity(delta):
	controller_velocity = Vector3.ZERO
	
	if prior_controller_velocities.size() > 0:
		for vel in prior_controller_velocities:
			controller_velocity += vel
		
		controller_velocity = controller_velocity / prior_controller_velocities.size()
	
	var relative_controller_position = (global_transform.origin - prior_controller_position)
	
	controller_velocity += relative_controller_position
	prior_controller_velocities.append(relative_controller_position)
	prior_controller_position = global_transform.origin
	controller_velocity /= delta;
		
	if prior_controller_velocities.size() > 30:
		prior_controller_velocities.remove(0)

func _button_pressed(button_index):
	print(str(button_index) + ":b")
	if button_index == 15:
		_grab()
		trigger_pressed = true
	#if button_index == 1 and !ui_tween.is_active() and controller_id == 2:
	#	_activate_ui();

func _button_released(button_index):
	if button_index == 15:
		trigger_pressed = false
		if held_object != null:
			_throw_rigidbody()
#
#func _activate_ui(): # NOT USED IN THIS PROJECT
#
#	var left_controller = get_parent().get_node("LeftController")
#	left_controller._toggle_ray()
#	if !ui.visible:
#		ui.scale = Vector3(1, 0, 1)
#		ui.visible = true
#		ui_tween.interpolate_property($UI, "scale", Vector3(1, 1, 0), Vector3(1, 1, 1), 0.2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
#		ui_tween.start()
#	else:
#		ui_tween.interpolate_property($UI, "scale", Vector3(1, 1, 1), Vector3(1, 1, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
#		ui_tween.start()
#		yield(ui_tween, "tween_completed")
#		ui.visible = false
#
#

func _toggle_ray():
	if !$Pointer.visible:
		$Pointer.visible = true
	else:
		$Pointer.visible = false

func _grab():
	if teleporting:
		return
	
	if held_object == null:
		_pickup_rigidbody()

func _pickup_rigidbody():
	var rigid_body = null
	
	var bodies = grab_area.get_overlapping_bodies()
	
	if len(bodies) > 0:
		for body in bodies:
			if body is RigidBody:
				if !("NOPICKUP" in body):
					rigid_body = body
					break
	
	if rigid_body != null:
		if controller_id == 1 and $Pointer.visible:
			_toggle_ray()
			temp_laser_disable = true
		
		held_object = rigid_body
		
		# save the objects original data
		held_object_data["mode"] = held_object.mode
		held_object_data["layer"] = held_object.collision_layer
		held_object_data["mask"] = held_object.collision_mask
		
		held_object.mode = RigidBody.MODE_STATIC
		held_object.collision_layer = 0	
		held_object.collision_mask = 0
		
		hand_mesh.visible = false
		
		if held_object is VR_Interactable_Rigidbody:
			held_object.controller = self
			held_object.picked_up()

func _throw_rigidbody():
	# If the VR controller is not holding any objects, we cannot throw anything!
	# If this somehow happens, simply return.
	if held_object == null:
		return
	
	
	if controller_id == 1 and temp_laser_disable:
			_toggle_ray()
			temp_laser_disable = false
	
	# Set the held object's RigidBody data back to the stored RigidBody data from the
	# _pickup_rigidbody function.
	held_object.mode = held_object_data["mode"]
	held_object.collision_layer = held_object_data["layer"]
	held_object.collision_mask = held_object_data["mask"]
	
	# Use the apply_impulse function to throw the RigidBody in the direction of the controller's velocity.
	print("controller vel: " + str(controller_velocity))
	held_object.apply_impulse(Vector3(0, 0, 0), controller_velocity)
	
	# If the held object extends the VR_Interactable_Rigidbody class...
	if held_object is VR_Interactable_Rigidbody:
		# Call the held object's dropped function, and set the controller variable to null.
		held_object.dropped()
		held_object.controller = null
	
	# Set the held_object variable to null, as the VR controller is no longer holding anything.
	held_object = null
	# Since nothing is beind held, make the hand_mesh visible so the VR controller still has a visible mesh.
	hand_mesh.visible = true
	
	