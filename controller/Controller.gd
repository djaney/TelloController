extends Node

@export var rc_speed : int = 100

var _video_ctrl_socket : PacketPeerUDP

const TEMP_LABEL = "Temp"

var _in_flight: bool = false
func _ready():
	_init_video_ctrl_socket()
	$Tello.connect("recived_telemery_temph", _update_temph)
	$Tello.connect("recived_telemery_h", _update_altitude)
	$HUD.connect("stream_on", _stream_on)
	$HUD.connect("video_on", _video_on)
	
	$HUD.in_flight = _in_flight
	$HUD.altitude = 0
	_update_temph(0)
	
	$Tello.start()
	
func _init_video_ctrl_socket() -> void:
	# warning-ignore:return_value_discarded
	_video_ctrl_socket = PacketPeerUDP.new()
	_video_ctrl_socket.bind(5002)
	
func _update_temph(temph: int):
	$HUD.temperature = temph

func _update_altitude(alt: int):
	$HUD.altitude = alt
	if alt == 0:
		_in_flight = false
	else:
		_in_flight = true
	$HUD.in_flight = _in_flight

func _process(_delta):
	_handle_rc()
	_handle_video_socket_messages()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if _in_flight:
			$Tello.land()
		else:
			$Tello.takeoff()
			
	
		
func _handle_rc():
	if not $Tello.is_active:
		return
		
	var left_right : int = 0
	var forward_backward : int = 0
	var up_down : int = 0
	var yaw : int = 0
		
	if Input.is_action_pressed("forward"):
		forward_backward = 1 * rc_speed
	elif Input.is_action_pressed("backward"):
		forward_backward = -1 * rc_speed
		
		
	if Input.is_action_pressed("strafe_left"):
		left_right = -1 * rc_speed
	elif Input.is_action_pressed("strafe_right"):
		left_right = 1 * rc_speed
		
	if Input.is_action_pressed("yaw_left"):
		yaw = -1 * rc_speed
	elif Input.is_action_pressed("yaw_right"):
		yaw = 1 * rc_speed
		
	if Input.is_action_pressed("up"):
		up_down = 1 * rc_speed
	elif Input.is_action_pressed("down"):
		up_down = -1 * rc_speed
		
	$Tello.rc(left_right, forward_backward, up_down, yaw)
	

func _handle_video_socket_messages():
	_video_ctrl_socket
	var count := _video_ctrl_socket.get_available_packet_count()
	if count < 1:
		return
	for _i in range(count):
		var bytes := _video_ctrl_socket.get_packet()
		var msg := bytes.get_string_from_ascii().rstrip("\n")
		_execute_socket_commands(msg)		

func _execute_socket_commands(cmd):
	print(cmd)
	if cmd == "streamon":
		$Tello.send_cmd("streamon")
		_video_ctrl_socket.set_dest_address("0.0.0.0", 5001)
		_video_ctrl_socket.put_packet("stream=1".to_ascii_buffer())
	elif cmd == "videoon":
		$Video.start()
		_video_ctrl_socket.set_dest_address("0.0.0.0", 5001)
		_video_ctrl_socket.put_packet("video=1".to_ascii_buffer())
	
func _stream_on():
	$Tello.send_cmd("streamon")
	
func _video_on():
	$Video.start()
