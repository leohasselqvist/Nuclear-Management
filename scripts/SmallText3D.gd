extends Spatial

export var text = "Nuclear Management" 
onready var label = get_node("Viewport/SmallText/HBoxContainer/VBoxContainer/Label/")

func set_text(new_value):
	text = new_value
	update_text()

func get_text():
	return text
# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()

func update_text():
	label.text = text