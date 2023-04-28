extends TextureRect

var http: HTTPClient
var tex : ImageTexture

func _ready():
	_fit_to_screen()
	tex = ImageTexture.new()
	http = HTTPClient.new()
	var timer = Timer.new()
	timer.name = "RetryTimer"
	timer.one_shot = true
	timer.connect("timeout", start)
	add_child(timer)
	set_process(false)

func _process(_delta):
	
	if http.has_response():
		_handle_response()
	else:
		_connect()	
	
func _connect():
	if http.get_status() == HTTPClient.STATUS_CONNECTING or \
		http.get_status() == HTTPClient.STATUS_RESOLVING or \
		http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		return
		
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		push_error("Unable to connect to video stream host")
		return
		
	
	var err = http.request(HTTPClient.METHOD_GET, "/video_feed", []);
	
	if err != Error.OK:
		push_error("Unable to retrieve frame")
		return
		
func _handle_response():
	if http.get_status() != HTTPClient.STATUS_BODY:
		return
	
	var image = Image.new()

	var buff: PackedByteArray = http.read_response_body_chunk();
	if len(buff) > 0:
		var err = image.load_jpg_from_buffer(buff)
		if err != Error.OK:
			push_error("Couldn't load the image.");

		texture = tex.create_from_image(image)
	
		http.poll()
	else:
		set_process(false)
		$RetryTimer.start(1)
		

		
	
func start():
	var err: Error = http.connect_to_host("127.0.0.1", 5000)
	if err != Error.OK:
		push_error("Unable to connect to video stream host")
	set_process(true)
	
func _fit_to_screen():
	var resolution = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	size = resolution
