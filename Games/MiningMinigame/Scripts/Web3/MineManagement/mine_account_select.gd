extends AccountDisplayEntry

@export var token_displayable:DisplayableAsset

func setup_account_entry(name:String,account_data:Dictionary) -> void:
	super.setup_account_entry(name,account_data)
	
	button.disabled = true
	var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager")
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(menu_manager.house_data["houseName"])
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(data["campaignName"],house_pda)
	
	var campaign_token:Token = await SolanaService.asset_manager.get_asset_from_mint(data["rewardMint"],true,false)
	campaign_token.token_account = ClubhousePDA.get_campaign_vault_pda(campaign_pda)
	campaign_token.decimals = data["rewardMintDecimals"]
	await token_displayable.set_data(campaign_token)
	button.disabled = false
	
