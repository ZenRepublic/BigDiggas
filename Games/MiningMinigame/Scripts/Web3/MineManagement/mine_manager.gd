extends Node
class_name MineManager

@onready var screen_manager:ScreenManager = $ScreenManager

@export var house_name:String
@export var house_currency:String

@export var mine_screen_manager:ScreenManager
@export var mine_account_display_system:AccountDisplaySystem
@export var mine_create_handler:MineCreateHandler

@export var mine_display:MineDisplay

@export var mines_list:Container
@export var mine_creator:MineCreateHandler

var house_pda:Pubkey
var currency_mint:Pubkey

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	house_pda = ClubhousePDA.get_house_pda(house_name)
	currency_mint = Pubkey.new_from_string(house_currency)
	
	mine_account_display_system.on_account_selected.connect(load_mine)
	
func on_visibility_changed() -> void:
	if self.visible:
		await refresh_mines_list()
		
func refresh_mines_list() -> void:
	screen_manager.switch_active_panel(0)
	var filter:Array = [{"memcmp" : { "offset":8, "bytes": house_pda.to_string()}}]
	await mine_account_display_system.refresh_list("Campaign","campaignName",filter)
	screen_manager.switch_active_panel(2)
		
func show_create_mine() -> void:
	mine_screen_manager.switch_active_panel(2)
	
func create_new_mine() -> void:
	screen_manager.switch_active_panel(1)
	
	var mine_data:Dictionary = mine_create_handler.get_data()
	var mine_name:String = mine_data["campaignName"]
	var reward_mint:Pubkey = mine_data["rewardMint"]
	var collection:Pubkey = mine_data["collection"]
	
	var reward_mint_decimals:int = await SolanaService.get_token_decimals(reward_mint.to_string())
	var fund_amount_lamports:int = floori(mine_data["fundAmount"]*pow(10,reward_mint_decimals))
	
	var max_reward_lamports:int = floori(mine_data["maxReward"]*pow(10,reward_mint_decimals))
	var player_claim_fee: int = floori(mine_data["rewardsTax"]*pow(10,9))
	
	var timespan:Dictionary = {
		"startTime":mine_data["startTime"],
		"endTime":mine_data["endTime"]
	}
	
	var nft_config:Dictionary = {
		"maxClubMemberEnergy":AnchorProgram.u8(mine_data["maxEnergy"]),
		"energyRechargeMinutes":mine_data["energyRechargeMinutes"]
	}

	var tx_data:TransactionData = await ClubhouseProgram.create_campaign(house_pda,currency_mint,mine_name,reward_mint,collection,fund_amount_lamports,max_reward_lamports,player_claim_fee,timespan,nft_config)
	
	screen_manager.switch_active_panel(2)
	pass
	
func load_mine(mine_data:Dictionary) -> void:
	mine_screen_manager.switch_active_panel(1)
	await mine_display.set_mine_data(mine_data)
	mine_screen_manager.switch_active_panel(3)
