extends Node
class_name MineManager

@onready var screen_manager:ScreenManager = $ScreenManager

@export var house_name:String

@export var mine_screen_manager:ScreenManager
@export var mine_account_display_system:AccountDisplaySystem
@export var mine_create_handler:MineCreateHandler

@export var mine_display:MineDisplay

@export var mines_list:Container
@export var mine_creator:MineCreateHandler

var house_pda:Pubkey

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	house_pda = ClubhousePDA.get_house_pda(house_name)
	mine_account_display_system.on_account_selected.connect(load_mine)
	
func on_visibility_changed() -> void:
	if self.visible:
		screen_manager.switch_active_panel(0)
		var campaigns:Dictionary = await ClubhouseProgram.fetch_all_accounts_of_type("Campaign",[{"memcmp" : { "offset":8, "bytes": house_pda.to_string()}}])
		for key in campaigns.keys():
			var campaign_data:Dictionary = campaigns[key]
			var campaign_name_bytes:PackedByteArray = campaign_data["houseName"] as PackedByteArray
			mine_account_display_system.add_account(campaign_name_bytes.get_string_from_utf8(),campaign_data)
		screen_manager.switch_active_panel(2)
		
func show_create_mine() -> void:
	mine_screen_manager.switch_active_panel(2)
	
func create_new_mine() -> void:
	screen_manager.switch_active_panel(1)
	
	var mine_data:Dictionary = mine_create_handler.get_data()
	#var house_name:String = house_data["houseName"]
	#var manager_collection:Pubkey = house_data["managerCollection"]
	#var house_currency:Pubkey = house_data["houseCurrency"] if  house_data["houseCurrency"] != null else WRAPPED_SOL
	#if house_currency == null:
		#house_currency = WRAPPED_SOL
	#
	#var currency_decimals:int = await SolanaService.get_token_decimals(house_currency.to_string())
	#var creation_fee_lamports:int = floori(house_data["campaignCreationFee"] * pow(10,currency_decimals))
	#var manager_discount_lamports:int = floori(house_data["campaignManagerDiscount"] * pow(10,currency_decimals))
	#var claim_fee_lamports:int =  floori(house_data["claimFee"] * pow(10,9))
	#
	#var house_config:Dictionary = {
		#"oracleKey":house_data["oracleKey"] if house_data["oracleKey"] != null else SystemProgram.get_pid(),
		#"campaignCreationFee":AnchorProgram.u64(creation_fee_lamports),
		#"campaignManagerDiscount":AnchorProgram.u64(manager_discount_lamports),
		#"claimFee":AnchorProgram.u64(claim_fee_lamports),
		#"rewardsTax":AnchorProgram.u64(house_data["rewardsTax"]),
	#}
	#print("name: ",house_name, " manager collection: ",manager_collection.to_string(), " currency: ",house_currency.to_string())
	#print(house_config)
	##var tx_data:TransactionData = await ClubhouseProgram.move_right()
	#var tx_data:TransactionData = await ClubhouseProgram.create_house(house_name,manager_collection,house_currency,house_config)
	
	screen_manager.switch_active_panel(2)
	pass
	
func load_mine(mine_data:Dictionary) -> void:
	mine_screen_manager.switch_active_panel(1)
	await mine_display.set_mine_data(mine_data)
	mine_screen_manager.switch_active_panel(3)
