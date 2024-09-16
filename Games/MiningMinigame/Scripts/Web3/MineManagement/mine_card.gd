extends Node
class_name MineCard

@export var mine_name_label:Label
@export var collection_displayable:DisplayableAsset
@export var mine_manager_displayable:DisplayableAsset
@export var mine_token_displayable:DisplayableAsset
@export var max_reward_label:NumberLabel
@export var digga_details:DiggaDetails

@export var miner_display_system:AssetDisplaySystem

@export var end_time_label:Label
var curr_selected_mine_data:Dictionary

func _process(delta: float) -> void:
	if curr_selected_mine_data.size() > 0:
		var utc_timestamp:float = Time.get_unix_time_from_system()
		end_time_label.text = format_time(curr_selected_mine_data["timeSpan"]["endTime"] - utc_timestamp)
		
# Called when the node enters the scene tree for the first time.
func set_mine_data(data:Dictionary) -> void:
	curr_selected_mine_data = data
	
	mine_name_label.text = data["campaignName"]
	
	var collection_asset:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["collection"],true)
	collection_displayable.set_data(collection_asset)
	var nft_collection:NFTCollection = NFTCollection.new()
	nft_collection.devnet_collection_id = data["collection"].to_string()
	nft_collection.mainnet_collection_id = data["collection"].to_string()
	miner_display_system.collection_filter = [nft_collection]
	miner_display_system.setup(SolanaService.asset_manager.get_nfts_from_collection(nft_collection))
	miner_display_system.on_asset_selected.connect(show_details)
	
	if data["manager"] != null:
		var mine_manager:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["manager"])
		if mine_manager!=null:
			mine_manager_displayable.set_data(mine_manager)
		
	var campaign_token:Token = await SolanaService.asset_manager.get_asset_from_mint(data["rewardMint"],true)
	campaign_token.decimals = data["rewardMintDecimals"]
	mine_token_displayable.set_data(campaign_token)
	
	max_reward_label.set_value(data["maxRewardsPerGame"]/pow(10,data["rewardMintDecimals"]))
	
func show_details(nft:Nft) -> void:
	#var campaign_pda
	var data:Dictionary = await ClubhouseProgram.fetch_account_of_type("CampaignPlayer",ClubhousePDA.get_campaign_player_pda(nft.mint,nft.mint))
	digga_details.set_digga(nft,curr_selected_mine_data["nftEnergyConfig"]["maxPlayerEnergy"],data)
	
func format_time(timestamp: int) -> String:
	var hours = int(timestamp / 3600)
	var minutes = int((timestamp % 3600) / 60)
	var seconds = int(timestamp % 60)

	return str(hours) + "h " + str(minutes) + "m " + str(seconds) + "s"
