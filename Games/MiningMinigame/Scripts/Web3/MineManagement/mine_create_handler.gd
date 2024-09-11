extends Node
class_name MineCreateHandler

@export_category("Main Settings")
@export var general_input_field_system:InputFieldSystem
@export var token_selection:OptionButton
@export var fund_input_field:InputField
@export var max_fund_button:Button
@export var token_visuals:Array[TextureRect]

@export_category("Payment Settings")
@export var manager_selector:AssetSelector
@export var creation_fee_label:Label
@export var create_mine_button:Button

@export_category("NFT Miner Settings")
@export var nft_input_field_system:InputFieldSystem
@export var collection_selection:OptionButton
@export var max_reward_field:InputField

var server_data_loaded:bool

var selected_token:Token
var selected_collection:Nft
var manager_mint:Pubkey

signal on_create_pressed(mine_data:Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	update_button_state()
	general_input_field_system.on_fields_updated.connect(update_button_state)
	nft_input_field_system.on_fields_updated.connect(update_button_state)
	
	token_selection.item_selected.connect(select_token)
	collection_selection.item_selected.connect(select_collection)
	
	manager_selector.on_selected.connect(update_manager_selection)
	
	max_fund_button.pressed.connect(set_max_fund)	
	create_mine_button.pressed.connect(package_input_data)
	
	self.visibility_changed.connect(fetch_server_data)
	pass # Replace with function body.
	
func fetch_server_data() -> void:
	if self.visible and !server_data_loaded:
		await fill_option_fields()
		server_data_loaded = true
	
func fill_option_fields() -> void:
	var data:Dictionary = await RubianServer.get_mine_manager_data()
	
	var token_idx:int=token_selection.item_count
	for token in data["verified_tokens"]:
		var mint:Pubkey = Pubkey.new_from_string(token["token_id"])
		#var token_data:Token = await SolanaService.asset_manager.get_asset_from_mint(mint)
		token_selection.add_item(token["name"],token_idx)
		token_selection.set_item_metadata(token_idx,mint)
		token_idx+=1
	
	var collection_idx:int=collection_selection.item_count
	for collection in data["verified_collections"]:
		var mint:Pubkey = Pubkey.new_from_string(collection["collection_id"])
		#var token_data:Token = await SolanaService.asset_manager.get_asset_from_mint(mint)
		collection_selection.add_item(collection["name"],collection_idx)
		collection_selection.set_item_metadata(collection_idx,mint)
		collection_idx+=1
		
func select_token(selected_idx:int) -> void:
	var new_token:Pubkey = token_selection.get_item_metadata(selected_idx)

	if new_token != selected_token:
		fund_input_field.clear()
	
	selected_token = await SolanaService.asset_manager.get_asset_from_mint(new_token)
	fund_input_field.max_value = await selected_token.get_balance()
	
	#max_reward_field.text = ""
	var item_icon:Texture2D = token_selection.get_item_icon(selected_idx)
	if item_icon!=null:
		for visual in token_visuals:
			visual.texture = token_selection.get_item_icon(selected_idx)

	update_button_state()
	
	
func select_collection(selected_idx:int) -> void:
	var new_collection = collection_selection.get_item_metadata(selected_idx)
	selected_collection = await SolanaService.asset_manager.get_asset_from_mint(new_collection)
	update_button_state()
		
func update_manager_selection(selected_nft:Nft) -> void:
	if selected_nft == null:
		manager_mint = null
		creation_fee_label.text = "0.1 SOL"
		return
	
	manager_mint = selected_nft.mint
	creation_fee_label.text = "FREE"
	
func update_button_state() -> void:
	var all_fields_valid:bool = true
	if !general_input_field_system.get_inputs_valid():
		all_fields_valid = false
	
	if !nft_input_field_system.get_inputs_valid():
		all_fields_valid = false
		
	if token_selection.get_selected_id() == -1 or collection_selection.get_selected_id() == -1:
		all_fields_valid = false
		
	var fund_amount:float = float(fund_input_field.text)
	if fund_amount == 0:
		fund_input_field.clear()
		all_fields_valid=false
	
	create_mine_button.disabled = !all_fields_valid
	
func set_max_fund() -> void:
	fund_input_field.text = str(fund_input_field.max_value)
	
func get_campaign_end_timestamp(campaign_duration_in_hours:int) -> float:
	var utc_timestamp:float = Time.get_unix_time_from_system()
	#timestamp is in seconds, so we need to convert hours to seconds and add it to the timestamp
	var duration_in_seconds:int = campaign_duration_in_hours*3600
	var end_timestamp = utc_timestamp + duration_in_seconds
	return end_timestamp
	
	
func package_input_data() -> void:
	var general_input_data:Array = general_input_field_system.get_fields_data()
	var nft_input_data:Array = nft_input_field_system.get_fields_data()
	var mine_data:Dictionary = {
		"name":general_input_data[0],
		"duration": get_campaign_end_timestamp(general_input_data[1]),
		"currency":token_selection.get_item_metadata(token_selection.get_selected_id()),
		"fund_amount":general_input_data[2],
		"miner_collection":collection_selection.get_item_metadata(collection_selection.get_selected_id()),
		"miner_energy":nft_input_data[0],
		"max_payout":nft_input_data[1],
		"manager":manager_mint
	}
	
	on_create_pressed.emit(mine_data)
