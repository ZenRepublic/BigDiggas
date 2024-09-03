extends Camera2D
class_name PainterInput

@export var min_zoom:float = 0.6
@export var max_zoom:float = 3.0
var zoom_tick = max_zoom / 20
var curr_zoom:float

var start_pos
var movement_enabled=false

signal on_zoom
signal on_mouse_position_updated
signal on_click

func _ready():
	start_pos = global_position
	curr_zoom = zoom.x

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Reset"):
		zoom = Vector2.ONE
		global_position = start_pos
		

func _input(event: InputEvent) -> void:		
	if event is InputEventMouseButton:	
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			emit_signal("on_left_mouse_click")
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			movement_enabled = event.is_pressed()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && event.is_pressed():
			zoom_camera(true)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.is_pressed():
			zoom_camera(false)
		
			
	if event is InputEventMouseMotion:
		emit_signal("on_mouse_position_updated",event.relative)
		if movement_enabled:
			# negative instead of positive to invert
			global_position -= event.relative
		
func zoom_camera(zoom_in:bool) -> void:
	emit_signal("on_zoom",zoom_in)
	print("ZOOM")
	if zoom_in:
		curr_zoom += zoom_tick
	else:
		curr_zoom -= zoom_tick
		
	curr_zoom = clamp(curr_zoom,min_zoom,max_zoom)
	zoom = Vector2(curr_zoom,curr_zoom)
	pass
