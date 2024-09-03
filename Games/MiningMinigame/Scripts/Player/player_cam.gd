extends Camera2D
class_name PlayerCamera

@export var min_zoom:float = 0.6
@export var max_zoom:float = 3.0

@export var shake_strength: float = 20.0
@export var shake_duration: float = 0.5
@export var shake_frequency: float = 20.0

var zoom_tick = max_zoom / 20
var curr_zoom:float
var center_pos:Vector2

@export var input_handler:PlayerInput

var shake_timer: float = 0.0
var original_position: Vector2
var time_since_last_shake: float = 0.0

signal on_camera_zoom(amount:float)
# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = position
	call_deferred("set_center_pos")
	
	input_handler.on_zoom.connect(zoom_camera)
	curr_zoom = min_zoom
	zoom = Vector2(curr_zoom,curr_zoom)
	
func set_center_pos() -> void:
	center_pos = self.global_position
	
func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		time_since_last_shake += delta

		# Only update the position based on the frequency
		if time_since_last_shake >= 1.0 / shake_frequency:
			time_since_last_shake = 0.0

			# Calculate a random offset
			var offset_x = (randf() * 2 - 1) * shake_strength
			var offset_y = (randf() * 2 - 1) * shake_strength
			position = original_position + Vector2(offset_x, offset_y)

		# Stop the shake if the timer has expired
		if shake_timer <= 0:
			position = original_position
	else:
		position = original_position
		
# Function to start the screen shake
func start_shake(duration: float = -1.0, strength: float = -1.0, frequency: float = -1.0):
	if duration > 0:
		shake_duration = duration
	if strength > 0:
		shake_strength = strength
	if frequency > 0:
		shake_frequency = frequency
	shake_timer = shake_duration
	time_since_last_shake = 0.0


func zoom_camera(zoom_in:bool) -> void:
	var old_zoom = curr_zoom
	var old_mouse_pos:Vector2 = get_global_mouse_position()	
	if zoom_in:
		curr_zoom += zoom_tick
	else:
		curr_zoom -= zoom_tick
	curr_zoom = clamp(curr_zoom,min_zoom,max_zoom)
	
	if curr_zoom == old_zoom:
		return
		
	zoom = Vector2(curr_zoom,curr_zoom)
	on_camera_zoom.emit(get_normalized_zoom())
	
	var mouse_pos = get_global_mouse_position()	
	var move_delta:Vector2
	if curr_zoom >= old_zoom:	
		move_delta = old_mouse_pos - mouse_pos
		self.global_position += move_delta
	else:
		var lerp_value:float = pow(1-get_normalized_zoom(),2)
		self.global_position = lerp(self.global_position,center_pos,lerp_value)
		
	original_position = self.position
	pass

func get_normalized_zoom() -> float:
	return (curr_zoom - min_zoom) / (max_zoom - min_zoom)
