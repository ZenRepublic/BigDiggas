extends Node
class_name PlayerInput

@export var mouse_sensitivity:float = 2.0
@export var neutral_cursor:Texture2D
@export var pressed_cursor:Texture2D
@export var cursor_hotspot:Vector2
var start_pos
var movement_enabled=false

var mouse_position:Vector2
var input_enabled:bool=true
var mouse_active:bool=false

signal on_zoom(zoom_in:bool)
signal on_reset
signal on_mouse_position_updated(mouse_delta:Vector2)
signal on_click
signal on_right_click(is_pressed:bool)
signal on_escape

func _ready() -> void:
	show_mouse(mouse_active)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Reset"):
		on_reset.emit()
		

func _input(event: InputEvent) -> void:		
	if !input_enabled:
		return
	
	if event.is_action_pressed("Escape"):
		on_escape.emit()
		
	if event is InputEventMouseButton:	
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				Input.set_custom_mouse_cursor(pressed_cursor,Input.CursorShape.CURSOR_ARROW,cursor_hotspot)
				on_click.emit()
			else:
				Input.set_custom_mouse_cursor(neutral_cursor,Input.CursorShape.CURSOR_ARROW,cursor_hotspot)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			on_right_click.emit(event.is_pressed())

				
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			movement_enabled = event.is_pressed()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && event.is_pressed():
			on_zoom.emit(true)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.is_pressed():
			on_zoom.emit(false)
		
			
	if event is InputEventMouseMotion:
		mouse_position = event.position
		if movement_enabled:
			#sent inverted event.relative because thats more intuitive to scroll
			on_mouse_position_updated.emit(-event.relative*mouse_sensitivity)
		
func show_mouse(show:bool) -> void:
	mouse_active=show
	
	if show:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
