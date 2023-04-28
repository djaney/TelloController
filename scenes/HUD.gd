extends Control

signal stream_on
signal video_on

var temperature : int :
	set(value):
		$Container/Left/TempLabel.text = "TEMP: " + str(value)
		if value >= 40:
			$Container/Left/TempLabel.add_theme_color_override("font_color", Color.RED)
		else:
			$Container/Left/TempLabel.add_theme_color_override("font_color", Color.GREEN)
var in_flight : bool :
	set(value):
		if value:
			$Container/Left/InFlightLabel.text = "FLY"
			$Container/Left/InFlightLabel.add_theme_color_override("font_color", Color.RED)
		else:
			$Container/Left/InFlightLabel.text = "LAND"
			$Container/Left/InFlightLabel.add_theme_color_override("font_color", Color.GREEN)
			
var altitude : int :
	set(value):
		$Container/Center/Altimeter.altitude = value

func _ready():
	
	$Container/Right/StreamOn.connect("button_down", _stream_on)
	$Container/Right/Video.connect("button_down", _video_on)
	
	var resolution = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	size = resolution
	
func _stream_on():
	stream_on.emit()

func _video_on():
	video_on.emit()
