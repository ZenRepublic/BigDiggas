extends Node
class_name InputFieldSystem

#@export var input_fields: Array[InputField]
@export var input_fields: Dictionary

signal on_input_submit
signal on_fields_updated
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for key in input_fields.keys():
		var field = get_node(input_fields[key]) as InputField
		field.on_field_updated.connect(notify_change)
		
func notify_change() -> void:
	on_fields_updated.emit()

func confirm_input() -> void:
	on_input_submit.emit(get_fields_data())
	
func get_inputs_valid() -> bool:
	var all_valid=true
	for key in input_fields.keys():
		var field = get_node(input_fields[key]) as InputField
		if !field.is_valid():
			all_valid=false
	return all_valid
		
func get_fields_data()-> Dictionary:
	var fields_data:Dictionary
	for key in input_fields.keys():
		var field = get_node(input_fields[key]) as InputField
		fields_data[key] = field.get_field_value()
		
	return fields_data
		
func clear_fields() -> void:
	for key in input_fields.keys():
		var field = get_node(input_fields[key]) as InputField
		field.clear()
		
func get_field(name:String) -> InputField:
	return get_node(input_fields[name]) as InputField
