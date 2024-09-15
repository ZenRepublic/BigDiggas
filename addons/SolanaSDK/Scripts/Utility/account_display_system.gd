extends Node
class_name AccountDisplaySystem

@export var container:Container
@export var entry_scn:PackedScene
@export var no_entries_overlay:Control
@export var bring_new_to_back:bool=true

var accounts:Dictionary

signal on_account_selected(account_data:Dictionary)

func _ready() -> void:
	if no_entries_overlay!=null:
		no_entries_overlay.visible=true

func add_account(account_name:String,account_data:Dictionary) -> void:
	if no_entries_overlay!=null:
		no_entries_overlay.visible=false
		
	var entry_instance = entry_scn.instantiate()
	container.add_child(entry_instance)
	if bring_new_to_back:
		container.move_child(entry_instance,0)
		
	entry_instance.text = account_name
	
	accounts[entry_instance] = account_data
	entry_instance.pressed.connect(handle_press.bind(entry_instance))
	
func handle_press(selected_account) -> void:
	var account_data:Dictionary = accounts[selected_account]
	on_account_selected.emit(account_data)
	
func clear_display() -> void:
	for key in accounts.keys():
		var account_entry = key
		account_entry.pressed.disconnect(handle_press.bind(account_entry))
		account_entry.queue_free()
	accounts = {}
