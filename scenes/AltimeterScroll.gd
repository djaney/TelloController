extends TextureRect

var d : int = 20
var w : int = 100
var max_h : int = 3000

func _ready():
	size.y = d * max_h
	var tex: ImageTexture = ImageTexture.new()
	texture = ImageTexture.new()

func _draw():
	var color: Color = get_parent().hud_color
	for i in range(max_h):
		draw_line(Vector2(0, i * d), Vector2(w, i * d), color, 1)
		
	
