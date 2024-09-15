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

@export var close_button:BaseButton
var curr_selected_mine_data:Dictionary

func _process(delta: float) -> void:
	if curr_selected_mine_data != null:
		var utc_timestamp:float = Time.get_unix_time_from_system()
		if utc_timestamp >= curr_selected_mine_data["endTime"]:
			if close_button.disabled:
				close_button.disabled=false
				close_button.text = "CLAIM AND CLOSE"
			return
			
		close_button.disabled=true
		close_button.text = "CLOSES IN %s" % format_time(curr_selected_mine_data["endTime"] - utc_timestamp)
		
		
# Called when the node enters the scene tree for the first time.
func set_mine_data(data:Dictionary) -> void:
	curr_selected_mine_data = data
	
	var mine_name_bytes:PackedByteArray = data["campaignName"] as PackedByteArray
	mine_name_label.text = mine_name_bytes.get_string_from_utf8()
	
	var collection_asset:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["collection"],true)
	collection_displayable.set_data(collection_asset)
	
	if data["managerMint"] != null:
		var mine_manager:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["managerMint"])
		mine_manager_displayable.set_data(mine_manager)
		
	var campaign_token:Token = await SolanaService.asset_manager.get_asset_from_mint(data["rewardMint"],true)
	campaign_token.decimals = data["rewardMintDecimals"]
	mine_token_displayable.set_data(campaign_token)
	
	total_games_label.text = str(data["totalGames"])
	max_reward_label.text = str(data["config"]["maxReward"])
	unique_players_label.set_value(data["memberCount"])
	
	fees_collected.text = str(data["collectedFees"])
	
func format_time(timestamp: int) -> String:
	var hours = int(timestamp / 3600)
	var minutes = int((timestamp % 3600) / 60)
	var seconds = int(timestamp % 60)

	return str(hours) + "h " + str(minutes) + "m " + str(seconds) + "s"
