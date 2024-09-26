extends Node
class_name AccountDisplaySystem

@export var container:Container
@export var entry_scn:PackedScene
@export var no_entries_overlay:Control
@export var bring_new_to_back:bool=true

var accounts:Array[AccountDisplayEntry]

signal on_account_selected(account_data:Dictionary)

func _ready() -> void:
	if no_entries_overlay!=null:
		no_entries_overlay.visible=true
		
func refresh_list(account_keyword:String, identifier_keyword:String,filter:Array=[]) -> void:
	clear_display()
	var accounts:Dictionary = await ClubhouseProgram.fetch_all_accounts_of_type(account_keyword,filter)
	for key in accounts.keys():
		var data:Dictionary = accounts[key]
		var identifier = data[identifier_keyword]
		#identifier needs to be a string to give it to label. if packed byte array, then convert to string		
		#check against array variants: https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enum-globalscope-variant-type			
		if typeof(identifier) in [28,29,30,31,32,33]:
			var identifier_bytes:PackedByteArray = identifier as PackedByteArray
			identifier = identifier_bytes.get_string_from_utf8()
		elif typeof(identifier) != TYPE_STRING:
			identifier = str(identifier)
			
		add_account(identifier,data)
	

func add_account(account_name:String,account_data:Dictionary) -> void:
	if no_entries_overlay!=null:
		no_entries_overlay.visible=false
		
	var entry_instance:AccountDisplayEntry = entry_scn.instantiate() as AccountDisplayEntry
	container.add_child(entry_instance)
	if bring_new_to_back:
		container.move_child(entry_instance,0)
	
	entry_instance.setup_account_entry(account_name,account_data)
	entry_instance.on_selected.connect(handle_press)
	accounts.append(entry_instance)
	
func handle_press(selected_account:AccountDisplayEntry) -> void:
	on_account_selected.emit(selected_account.data)
	
func clear_display() -> void:
	for account in accounts:
		account.on_selected.disconnect(handle_press)
		account.queue_free()
	accounts.clear()
