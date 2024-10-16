extends Node
class_name MineRewardClaimer

@export var score_to_max_reward:float = 300
var house_data
var mine_data
var digga_data
var campaign_pda:Pubkey

var reward_mint_decimals:int
var max_reward_lamports:int

var campaign_token:Token
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	house_data = SceneManager.get_interscene_data("HouseData")
	if house_data == null:
		return
	mine_data = SceneManager.get_interscene_data("MineData")
	digga_data = SceneManager.get_interscene_data("DiggaData")
		
	reward_mint_decimals = mine_data["rewardMintDecimals"]
	campaign_token = await SolanaService.asset_manager.get_asset_from_mint(mine_data["rewardMint"],true)
	
	max_reward_lamports = mine_data["maxRewardsPerGame"]

	
func get_token_unit_price(in_lamports:bool=true) -> float:
	var score_point_value_in_reward_lamports:int = floori(max_reward_lamports/score_to_max_reward)
	
	if in_lamports:
		return score_point_value_in_reward_lamports
	else:
		var value_in_number:float = float(score_point_value_in_reward_lamports)/pow(10,reward_mint_decimals)
		return round(value_in_number*pow(10,reward_mint_decimals)) / pow(10,reward_mint_decimals)
	
func get_token_value(score:int, in_lamports:bool=true) -> float:
	var token_value_in_lamports:int = clamp(get_token_unit_price(true) * score,0,max_reward_lamports)
	
	if in_lamports:
		return token_value_in_lamports
	else:
		return float(token_value_in_lamports)/pow(10,reward_mint_decimals)
		
func get_reward_token_texture() -> Texture2D:
	if campaign_token == null:
		return null
	return campaign_token.image
	
func get_max_reward() -> float:
	return max_reward_lamports/pow(10,reward_mint_decimals)
		

func claim_reward(claim_amount:float) -> TransactionData:
	var reward_amount_lamports:int = clampi(claim_amount*pow(10,reward_mint_decimals),0,max_reward_lamports)
	var house_pda:Pubkey = mine_data["house"]
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(mine_data["campaignName"],house_pda)
	var reward_mint:Pubkey = mine_data["rewardMint"]
	var digga_mint:Pubkey = digga_data["mint"]
	var oracle:Pubkey = house_data["config"]["oracleKey"]
	
	var tx_data:TransactionData = await ClubhouseProgram.claim_reward(house_pda,oracle,campaign_pda,digga_mint,reward_mint,reward_amount_lamports)
	return tx_data
	
	
