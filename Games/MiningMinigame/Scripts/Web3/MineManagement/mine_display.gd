extends Node
class_name MineDisplay

@export var mine_name_label:Label
@export var collection_displayable:DisplayableAsset
@export var mine_manager_displayable:DisplayableAsset
@export var mine_token_displayable:DisplayableAsset
@export var total_games_label:Label
@export var unique_players_label:Label
@export var max_reward_label:NumberLabel

@export var fees_collected:Label

@export var close_button:TimedButton
var curr_selected_mine_data:Dictionary		

# Called when the node enters the scene tree for the first time.
func set_mine_data(data:Dictionary) -> void:
	curr_selected_mine_data = data
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(data["campaignName"],data["house"])
	mine_name_label.text = data["campaignName"]
	
	var collection_asset:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["nftConfig"]["collection"],true)
	if collection_asset!=null:
		collection_displayable.set_data(collection_asset)
	else:
		push_error("Collection NFT Failed to load...")
	
	if data["managerMint"] != null:
		var mine_manager:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["managerMint"])
		if mine_manager!=null:
			mine_manager_displayable.set_data(mine_manager)
		
	var campaign_token:Token = await SolanaService.asset_manager.get_asset_from_mint(data["rewardMint"],true,false)
	campaign_token.token_account = ClubhousePDA.get_campaign_vault_pda(campaign_pda)
	campaign_token.decimals = data["rewardMintDecimals"]
	await mine_token_displayable.set_data(campaign_token)
	
	total_games_label.text = str(data["totalGames"])
	unique_players_label.text = str(data["playerCount"])
	max_reward_label.set_value(data["maxRewardsPerGame"]/pow(10,data["rewardMintDecimals"]))
	
	fees_collected.text = "%s SOL" % str(data["unclaimedSolFees"]/pow(10,9))
	
	close_button.start_timer(data["timeSpan"]["endTime"])
