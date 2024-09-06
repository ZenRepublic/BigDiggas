extends Node
class_name InputFieldSystem

@export var input_fields: Array[InputField]

signal on_input_submit
signal on_fields_updated
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for field in input_fields:
		field.on_field_updated.connect(notify_change)
		
func notify_change() -> void:
	on_fields_updated.emit()

func confirm_input() -> void:
	on_input_submit.emit(get_fields_data())
	
func get_inputs_valid() -> bool:
	var all_valid=true
	for field in input_fields:
		if !field.is_valid():
			all_valid=false
			break
	return all_valid
		
func get_fields_data()-> Array:
	var fields_data:Array
	for input in input_fields:
		fields_data.append(input.get_field_value())
	
	return fields_data
		
func clear_fields() -> void:
	for field in input_fields:
		field.clear()
