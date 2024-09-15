extends Node
class_name HouseManager

@onready var screen_manager:ScreenManager = $ScreenManager

@export var house_screen_manager:ScreenManager
@export var house_display:HouseDisplay
@export var house_create_data_handler:HouseCreateDataHandler
@export var house_edit_data_handler:HouseEditDataHandler

@export var house_account_display_system:AccountDisplaySystem

var WRAPPED_SOL:Pubkey = Pubkey.new_from_string("So11111111111111111111111111111111111111112")

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	house_account_display_system.on_account_selected.connect(load_house)
	
func on_visibility_changed() -> void:
	if self.visible:
		screen_manager.switch_active_panel(0)
		var houses:Dictionary = await ClubhouseProgram.fetch_all_accounts_of_type("House")
		for key in houses.keys():
			var house_data:Dictionary = houses[key]
			var house_name_bytes:PackedByteArray = house_data["houseName"] as PackedByteArray
			house_account_display_system.add_account(house_name_bytes.get_string_from_utf8(),house_data)
		screen_manager.switch_active_panel(2)
		
func show_create_house() -> void:
	house_screen_manager.switch_active_panel(2)
		
func create_new_house() -> void:
	screen_manager.switch_active_panel(1)
	
	var house_data:Dictionary = house_create_data_handler.get_data()
	var house_name:String = house_data["houseName"]
	var manager_collection:Pubkey = house_data["managerCollection"]
	var house_currency:Pubkey = house_data["houseCurrency"] if  house_data["houseCurrency"] != null else WRAPPED_SOL
	if house_currency == null:
		house_currency = WRAPPED_SOL
	
	var currency_decimals:int = await SolanaService.get_token_decimals(house_currency.to_string())
	var creation_fee_lamports:int = floori(house_data["campaignCreationFee"] * pow(10,currency_decimals))
	var manager_discount_lamports:int = floori(house_data["campaignManagerDiscount"] * pow(10,currency_decimals))
	var claim_fee_lamports:int =  floori(house_data["claimFee"] * pow(10,9))
	
	var house_config:Dictionary = {
		"oracleKey":house_data["oracleKey"] if house_data["oracleKey"] != null else SystemProgram.get_pid(),
		"campaignCreationFee":AnchorProgram.u64(creation_fee_lamports),
		"campaignManagerDiscount":AnchorProgram.u64(manager_discount_lamports),
		"claimFee":AnchorProgram.u64(claim_fee_lamports),
		"rewardsTax":AnchorProgram.u64(house_data["rewardsTax"]),
	}
	print("name: ",house_name, " manager collection: ",manager_collection.to_string(), " currency: ",house_currency.to_string())
	print(house_config)
	#var tx_data:TransactionData = await ClubhouseProgram.move_right()
	var tx_data:TransactionData = await ClubhouseProgram.create_house(house_name,manager_collection,house_currency,house_config)
	
	screen_manager.switch_active_panel(2)
	pass
	
func edit_selected_house() -> void:
	screen_manager.switch_active_panel(1)
	
	var house_data:Dictionary = house_edit_data_handler.get_data()
	var house_name_bytes:PackedByteArray = house_display.curr_selected_house_data["houseName"] as PackedByteArray
	var house_name:String = house_name_bytes.get_string_from_utf8()
	
	var currency_decimals:int =  house_edit_data_handler.decimals
	var creation_fee_lamports:int = floori(house_data["campaignCreationFee"] * pow(10,currency_decimals))
	var manager_discount_lamports:int = floori(house_data["campaignManagerDiscount"] * pow(10,currency_decimals))
	var claim_fee_lamports:int =  floori(house_data["claimFee"] * pow(10,9))
	
	var house_config:Dictionary = {
		"oracleKey":house_data["oracleKey"] if house_data["oracleKey"] != null else SystemProgram.get_pid(),
		"campaignCreationFee":AnchorProgram.u64(creation_fee_lamports),
		"campaignManagerDiscount":AnchorProgram.u64(manager_discount_lamports),
		"claimFee":AnchorProgram.u64(claim_fee_lamports),
		"rewardsTax":AnchorProgram.u64(house_data["rewardsTax"]),
	}
	
	var tx_data:TransactionData = await ClubhouseProgram.update_house(house_name,house_config)
	
	screen_manager.switch_active_panel(2)
	pass
	
func load_house(house_data:Dictionary) -> void:
	house_screen_manager.switch_active_panel(1)
	await house_display.set_house_data(house_data)
	house_screen_manager.switch_active_panel(3)
	
func close_selected_house() -> void:
	screen_manager.switch_active_panel(1)
	pass
	
func claim_creation_fees() -> void:
	screen_manager.switch_active_panel(1)
	pass
	
func claim_house_tax_fees() -> void:
	screen_manager.switch_active_panel(1)
	pass
