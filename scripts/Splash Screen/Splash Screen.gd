extends Node

var time = 2

func _ready():
	yield(utils.create_timer(0.5), "timeout")
	audio_player.play("the_first_sounds.wav", "Music")
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#audio_player.stop("Music")
		_on_VC_fading_complete(true)


func _on_VC_fading_complete(fade_music=false):
	if fade_music:
		audio_player.fade_out("Music", 2)
		time = 0.25
	$Control/HC/VC/opa_tween.interpolate_property($Blank, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Control/HC/VC/opa_tween.start()
	yield(utils.create_timer(time*2), "timeout")
	get_tree().change_scene("res://Scenes/Gameplay.tscn")