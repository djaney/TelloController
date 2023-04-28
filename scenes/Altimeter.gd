extends Label

var box_size = Vector2(100, 35)
var hud_color: Color = Color.GREEN
var initial_pos: Vector2
var target_pos: Vector2
var elapsed: float

var altitude : int :
	set(value):
		_set_scroll_position(value)
		text = str(value)
		
func _ready():
	_set_scroll_position(0, true)
	add_theme_color_override("font_color", hud_color)
	size = box_size
	
func _draw():
	draw_rect(
		Rect2(Vector2.ZERO, box_size + Vector2.RIGHT * 10),
		hud_color,
		false,
		3
	)
	
func _process(delta):
	var w : float = elapsed * 2
	if w >= 1:
		$Scroll.position = target_pos
	else:
		$Scroll.position = initial_pos.lerp(target_pos, w)
	elapsed += delta

func _set_scroll_position(alt, instant=false):
	
	var y = -($Scroll.max_h * $Scroll.d) + ($Scroll.d * alt) + 35
	
	if instant:
		$Scroll.position = Vector2(box_size.x + 20, y)
		initial_pos = $Scroll.position
		target_pos = $Scroll.position
		elapsed = 0.0
	else:
		initial_pos = $Scroll.position
		target_pos = Vector2(box_size.x + 20, y)
		elapsed = 0.0
