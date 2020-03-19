extends VBoxContainer

var time = 2
signal fading_complete

func _ready():
	$Name.modulate = Color(1, 1, 1, 0)
	$Subtitle.modulate = Color(1, 1, 1, 0)
	$Logo.modulate = Color(1, 1, 1, 0)
	yield(utils.create_timer(0.5), "timeout")
	$opa_tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$opa_tween.start()
	yield(utils.create_timer(1), "timeout")
	$opa_tween.interpolate_property($Name, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$opa_tween.start()
	yield(utils.create_timer(1), "timeout")
	$opa_tween.interpolate_property($Subtitle, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$opa_tween.start()
	yield(utils.create_timer(3), "timeout")
	emit_signal("fading_complete")
