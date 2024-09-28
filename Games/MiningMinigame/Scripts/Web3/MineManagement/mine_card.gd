extends Node
class_name MineCard

@export var mine_name_label:Label
@export var collection_displayable:DisplayableAsset
@export var mine_manager_displayable:DisplayableAsset
@export var mine_token_displayable:DisplayableAsset
@export var max_reward_label:NumberLabel
@export var digga_overview:DiggaOverview
@export var campaign_timer:TimedButton

@export var player_display_system:AssetDisplaySystem

var curr_selected_mine_data:Dictionary
var campaign_pda:Pubkey

var is_locked:bool=false

func _ready() -> void:
	player_display_system.on_asset_selected.connect(select_digga)
		
# Called when the node enters the scene tree for the first time.
func set_mine_data(data:Dictionary) -> void:
	curr_selected_mine_data = data
	campaign_pda = ClubhousePDA.get_campaign_pda(data["campaignName"],data["house"])
	
	mine_name_label.text = data["campaignName"]
	
	var collection_asset:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["nftConfig"]["collection"],true)
	await collection_displayable.set_data(collection_asset)
	var owned_collection_nfts:Array[WalletAsset] = SolanaService.asset_manager.get_owned_nfts_from_collection_key(collection_asset.mint)
	player_display_system.setup(owned_collection_nfts,true)
	
	if data["managerMint"] != null:
		var mine_manager:Nft = await SolanaService.asset_manager.get_asset_from_mint(data["managerMint"])
		if mine_manager!=null:
			mine_manager_displayable.set_data(mine_manager)
		
	var campaign_token:Token = await SolanaService.asset_manager.get_asset_from_mint(data["rewardMint"],true,false)
	campaign_token.token_account = ClubhousePDA.get_campaign_vault_pda(campaign_pda)
	campaign_token.decimals = data["rewardMintDecimals"]
	await mine_token_displayable.set_data(campaign_token)
	
	max_reward_label.set_value(data["maxRewardsPerGame"]/pow(10,data["rewardMintDecimals"]))
	
	campaign_timer.start_timer(data["timeSpan"]["endTime"])
	if campaign_timer.is_finished():
		disable_mine()
	else:
		campaign_timer.on_timer_finished.connect(disable_mine)
	
func disable_mine() -> void:
	digga_overview.lock_selection(true)
	is_locked=true
	pass
	

func select_digga(nft:Nft) -> void:
	if is_locked:
		return
	#var campaign_pda
	var campaign_player_pda:Pubkey = ClubhousePDA.get_campaign_player_pda(campaign_pda,nft.mint)
	var player_data:Dictionary = await ClubhouseProgram.fetch_account_of_type("CampaignPlayer",campaign_player_pda)
	digga_overview.set_digga(nft,curr_selected_mine_data,player_data)
	
func get_selected_digga_nft() -> Pubkey:
	return digga_overview.digga_nft.mint
