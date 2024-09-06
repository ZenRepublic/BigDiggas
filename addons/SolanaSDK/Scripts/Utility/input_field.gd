extends LineEdit
class_name InputField

enum InputType{ALPHANUMERIC,INTEGER,DECIMAL}

@export var input_type = InputType.ALPHANUMERIC
@export var min_length:int = 0
@export var is_optional = false

@export_category("Number Field Settings")
@export var min_value:float = 0.0
@export var max_value:float = 999.0
@export var allow_zero:bool=true


var alphanumeric_regex = "^[a-zA-Z0-9 _\\-@]+$"
var integer_regex = "^[-+]?\\d+$"
var fraction_regex = "^[-+]?[0-9]+(\\.[0-9]+)?$"

@onready var input_constraint = RegEx.new()
var old_text

signal on_field_updated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	old_text = text
	text_changed.connect(handle_text_change)
	text_submitted.connect(handle_text_submit)
	focus_exited.connect(handle_focus_lost)
	match input_type:
		InputType.ALPHANUMERIC:
			input_constraint.compile(alphanumeric_regex)
		InputType.INTEGER:
			input_constraint.compile(integer_regex)
		InputType.DECIMAL:
			input_constraint.compile(fraction_regex)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func handle_text_change(new_text: String) -> void:
	#if input_constraint.search(new_text) == null:
		#text = old_text
		#caret_column = text.length()
		#return
	
	#old_text = text
	#text = new_text
	#caret_column = text.length()
	pass
	
func handle_focus_lost() -> void:
	text = validate_text(text)
	on_field_updated.emit()
	
func handle_text_submit(new_text:String) -> void:
	on_field_updated.emit()
	release_focus()
	text = validate_text(text)
	on_field_updated.emit()
	
func validate_text(new_text:String) -> String:
	var adjusted_text:String = new_text
	
	if new_text.length() >0 and input_constraint.search(new_text) == null:
		if input_type == InputType.INTEGER or input_type == InputType.DECIMAL:
			return str(min_value)
		else:
			return ""

	if input_type == InputType.INTEGER:
		var value:int = int(new_text)
		value = clamp(value,int(get_min_value()),int(get_max_value()))
		if value == 0 and not allow_zero:
			return ""
		adjusted_text = str(value)
	elif input_type == InputType.DECIMAL:
		var value:float = float(new_text)
		value = clamp(value,get_min_value(),get_max_value())
		if value == 0 and not allow_zero:
			return ""
		adjusted_text = str(value)
	else:
		adjusted_text = new_text
	
	return adjusted_text
		
	
func get_min_value() -> float:
	if min_value == -1:
		return -INF
	else:
		return min_value
		
func get_max_value() -> float:
	if max_value == -1:
		return INF
	else:
		return max_value
	
		
func is_valid() -> bool:
	if text.length() < min_length:
		return false
	if !is_optional && text.length()==0:
		return false
		
	if input_constraint.search(text) == null:
		return false
		
	return true
	
func get_field_value():
	match input_type:
		InputType.ALPHANUMERIC:
			return text
		InputType.INTEGER:
			return int(text)
		InputType.DECIMAL:
			return float(text)
	
