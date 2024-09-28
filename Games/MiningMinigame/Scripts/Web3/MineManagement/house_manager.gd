extends Node
class_name HouseManager

@onready var screen_manager:ScreenManager = $ScreenManager

@export var house_screen_manager:ScreenManager
@export var house_display:HouseDisplay
@export var house_create_input_system:HouseInputSystem
@export var house_edit_input_system:HouseInputSystem

@export var house_account_display_system:AccountDisplaySystem

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	house_account_display_system.on_account_selected.connect(load_house)
	
	house_account_display_system.set_list("House","houseName",[],false)
	
func on_visibility_changed() -> void:
	if self.visible:
		house_account_display_system.refresh_account_list()
		
func show_create_house() -> void:
	house_screen_manager.switch_active_panel(2)
		
func create_new_house() -> void:
	var house_data:Dictionary = house_create_input_system.get_input_data()
	
	var house_currency:Pubkey = house_data["houseCurrency"]
	if house_currency == null:
		house_currency = Pubkey.new_from_string(SolanaService.WRAPPED_SOL_CA)
	var currency_decimals:int = await SolanaService.get_token_decimals(house_currency.to_string())
		
	var oracleKey:Pubkey = house_data["oracleKey"]
	if oracleKey == null:
		oracleKey = SystemProgram.get_pid()
	
	var creation_fee_lamports:int = floori(house_data["campaignCreationFee"] * pow(10,currency_decimals))
	var manager_discount = house_data["campaignCreationFee"] - house_data["campaignManagerDiscount"]
	var manager_discount_lamports:int = floori(manager_discount * pow(10,currency_decimals))
	var claim_fee_lamports:int =  floori(house_data["claimFee"] * pow(10,9))
	var rewards_tax_basis_points:int = house_data["rewardsTax"]*10
	
	var house_config:Dictionary = {
		"oracleKey":oracleKey,
		"campaignCreationFee":AnchorProgram.u64(creation_fee_lamports),
		"campaignManagerDiscount":AnchorProgram.u64(manager_discount_lamports),
		"claimFee":AnchorProgram.u64(claim_fee_lamports),
		"rewardsTax":AnchorProgram.u64(rewards_tax_basis_points),
	}
	var tx_data:TransactionData = await ClubhouseProgram.create_house(house_data["houseName"],house_data["managerCollection"],house_currency,house_config)
	
	if tx_data.is_successful():
		house_account_display_system.refresh_account_list()
	
func edit_selected_house() -> void:
	var house_data:Dictionary = house_edit_input_system.get_input_data()
	var house_name:String = house_display.curr_selected_house_data["houseName"]
	
	var oracleKey:Pubkey = house_data["oracleKey"]
	if oracleKey == null:
		oracleKey = SystemProgram.get_pid()
	
	var currency_decimals:int =  house_display.decimals
	var creation_fee_lamports:int = floori(house_data["campaignCreationFee"] * pow(10,currency_decimals))
	
	var manager_discount = house_data["campaignCreationFee"] - house_data["campaignManagerDiscount"]
	var manager_discount_lamports:int = floori(manager_discount * pow(10,currency_decimals))
	var claim_fee_lamports:int =  floori(house_data["claimFee"] * pow(10,9))
	var rewards_tax_basis_points:int = house_data["rewardsTax"]*10
	
	var house_config:Dictionary = {
		"oracleKey":oracleKey,
		"campaignCreationFee":AnchorProgram.u64(creation_fee_lamports),
		"campaignManagerDiscount":AnchorProgram.u64(manager_discount_lamports),
		"claimFee":AnchorProgram.u64(claim_fee_lamports),
		"rewardsTax":AnchorProgram.u64(rewards_tax_basis_points),
	}
	
	var tx_data:TransactionData = await ClubhouseProgram.update_house(house_name,house_config)
	
	if tx_data.is_successful():
		house_account_display_system.refresh_account_list()
	
	
func close_selected_house() -> void:
	var house_data:Dictionary = house_display.curr_selected_house_data
	var house_name:String = house_data["houseName"]
	var house_currency:Pubkey = house_data["houseCurrency"]
	
	var tx_data:TransactionData = await ClubhouseProgram.close_house(house_name,house_currency)
	
	if tx_data.is_successful():
		house_screen_manager.switch_active_panel(0)
		house_account_display_system.refresh_account_list()
	
func claim_house_fees() -> void:
	var house_data:Dictionary = house_display.curr_selected_house_data
	var house_name:String = house_data["houseName"]
	var house_currency:Pubkey = house_data["houseCurrency"]
	
	var tx_data:TransactionData = await ClubhouseProgram.close_house(house_name,house_currency)
	
	if tx_data.is_successful():
		house_account_display_system.refresh_account_list()
		house_display.creation_fees_label.text = "0 SOL"
		house_display.house_fees_label.text = "0 SOL"
	
func load_house(house_data:Dictionary) -> void:
	house_screen_manager.switch_active_panel(1)
	await house_display.set_house_data(house_data)
	house_screen_manager.switch_active_panel(3)
