extends Node
class_name MineManager

@onready var screen_manager:ScreenManager = $ScreenManager

@export var mine_screen_manager:ScreenManager
@export var mine_account_display_system:AccountDisplaySystem
@export var mine_input_system:MineInputSystem
@export var mine_create_handler:MineCreateHandler

@export var mine_display:MineDisplay

@export var mines_list:Container
@export var mine_creator:MineCreateHandler

var house_pda:Pubkey
var currency_mint:Pubkey

var house_data:Dictionary

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	
	var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager")
	house_pda = ClubhousePDA.get_house_pda(menu_manager.house_name)
	currency_mint = Pubkey.new_from_string(menu_manager.house_currency)
	
	house_data = await ClubhouseProgram.fetch_account_of_type("House",house_pda)
	if house_data.size()!=0:
		mine_input_system.setup(house_data)
		
	var filter:Array = [{"memcmp" : { "offset":9, "bytes": house_pda.to_string()}}]
	mine_account_display_system.set_list("Campaign","campaignName",filter,false)
	
	mine_account_display_system.on_account_selected.connect(load_mine)
	
func on_visibility_changed() -> void:
	if self.visible:
		mine_account_display_system.refresh_account_list()

		
func show_create_mine() -> void:
	mine_screen_manager.switch_active_panel(2)
	
func create_new_mine() -> void:
	var mine_data:Dictionary = mine_input_system.get_input_data()
	var mine_name:String = mine_data["campaignName"]
	var reward_mint:Pubkey = mine_data["rewardCurrency"]
	
	var reward_mint_decimals:int = await SolanaService.get_token_decimals(reward_mint.to_string())
	var fund_amount_lamports:int = floori(mine_data["fundAmount"]*pow(10,reward_mint_decimals))
	
	var max_reward_lamports:int = floori(mine_data["maxReward"]*pow(10,reward_mint_decimals))
	var player_claim_fee: int = floori(mine_data["rewardsTax"]*pow(10,9))
	
	var timespan:Dictionary = {
		"startTime":Time.get_unix_time_from_system(),
		"endTime":get_campaign_end_timestamp(mine_data["campaignDuration"])
	}
	
	var nft_config:Dictionary = {
		"collection": mine_data["collection"],
		"maxPlayerEnergy":AnchorProgram.u8(mine_data["maxEnergy"]),
		"energyRechargeMinutes":AnchorProgram.option(null)
	}

	var tx_data:TransactionData = await ClubhouseProgram.create_campaign(house_pda,currency_mint,mine_name,reward_mint,fund_amount_lamports,max_reward_lamports,player_claim_fee,timespan,nft_config)
	
	if tx_data.is_successful():
		mine_account_display_system.refresh_account_list()
	
func get_campaign_end_timestamp(campaign_duration_in_hours:int) -> int:
	var utc_timestamp:float = Time.get_unix_time_from_system()
	#timestamp is in seconds, so we need to convert hours to seconds and add it to the timestamp
	var duration_in_seconds:int = campaign_duration_in_hours*3600
	var end_timestamp:int = floori(utc_timestamp + duration_in_seconds)
	return end_timestamp
	
func load_mine(mine_data:Dictionary) -> void:
	mine_screen_manager.switch_active_panel(1)
	await mine_display.set_mine_data(mine_data)
	mine_screen_manager.switch_active_panel(3)


func close_mine() -> void:
	var mine_name:String = mine_display.curr_selected_mine_data["campaignName"]
	var reward_mint:Pubkey = mine_display.curr_selected_mine_data["rewardMint"]
	
	var tx_data:TransactionData = await ClubhouseProgram.close_campaign(house_pda,mine_name,reward_mint)
	
	if tx_data.is_successful():
		mine_account_display_system.refresh_account_list()
		mine_screen_manager.switch_active_panel(0)
