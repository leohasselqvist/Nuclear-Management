extends Node

func play(sample_name, type):
	if type == "Music":
		$music_player.stop()
		$music_player.stream = load("res://Audio/" + type + "/" + sample_name)
		$music_player.play()
	elif type == "Sound":
		$audio_player.stream = load("res://Audio/" + type + "/" + sample_name)
		$audio_player.play()

func stop(type):
	if type == "Music":
		$music_player.stop()
	elif type == "All":
		$music_player.stop()
		$audio_player.stop()
	else:
		$audio_player.stop()
		
func change_volume(track, db):
	if track == "Music":
		$music_player.volume_db = db
	elif track ==  "All":
		$audio_player.volume_db = db
		$music_player.volume_db = db
	else:
		$audio_player.volume_db = db

func fade_out(track, fade_time):
	if track == "Music":
		$aud_tween.interpolate_property($music_player, "volume_db", $music_player.volume_db, -50, fade_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$aud_tween.start()
