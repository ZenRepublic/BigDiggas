extends Node

#for building custom program instructions, first goes function name, then array of accounts
#and then variables to pass in

#IMPORTANT:
#if no variables need to be passed in, write 'null'
#if multiple variables, put them in a dictionary
#if the variable is a class, pass it in as dictionary

@onready var program:AnchorProgram = $AnchorProgram

func get_pid() -> Pubkey:
		return Pubkey.new_from_string(program.get_pid())
		
#for fetching, gotta create a separate instance because these calls may happen in parallel which is not allowed
func spawn_program_instance()->AnchorProgram:
	var program_instance:AnchorProgram = AnchorProgram.new()
	program_instance.set_pid(program.get_pid())
	program_instance.set_json_file(program.get_json_file())
	program_instance.set_idl(program.get_idl())
	add_child(program_instance)
	return program_instance
		
func fetch_account_of_type(account_type:String,key:Pubkey) -> Dictionary:
	var program_instance = spawn_program_instance()
	program_instance.fetch_account(account_type,key)
	var account:Dictionary = await program_instance.account_fetched
	program_instance.queue_free()
	return account
	
func fetch_all_accounts_of_type(account_type:String,filter:Array=[]) -> Dictionary:
	var program_instance = spawn_program_instance()
	program_instance.fetch_all_accounts(account_type,filter)
	var accounts:Dictionary = await program_instance.accounts_fetched
	program_instance.queue_free()
	return accounts
		
func create_house(house_name:String,manager_collection:Pubkey,house_currency:Pubkey,house_config:Dictionary) -> TransactionData:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)

	var create_house_ix:Instruction = program.build_instruction("createHouse",[
		SolanaService.wallet.get_kp(),
		house_pda,
		ClubhousePDA.get_house_currency_vault(house_pda),
		SolanaService.wallet.get_pubkey(),
		house_currency,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid(),
	],{
		"managerCollection":AnchorProgram.option(manager_collection),
		"houseConfig": house_config,
		"houseName":house_name
	})
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([create_house_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	
func update_house(house_name:String,house_config:Dictionary) -> TransactionData:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)
	
	var create_house_ix:Instruction = program.build_instruction("updateHouse",[
		house_pda,
		SolanaService.wallet.get_kp(),
	],{
		"houseConfig": house_config,
	})
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([create_house_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	
func close_house(house_name:String, house_currency:Pubkey) -> TransactionData:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)
	
	var house_vault_token_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),house_currency)
	var delete_house_ix:Instruction = program.build_instruction("closeHouse",[
		house_pda,
		SolanaService.wallet.get_kp(),
		ClubhousePDA.get_house_currency_vault(house_pda),
		house_vault_token_account,
		house_currency,
		SolanaService.ATA_TOKEN_PID,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
	],null)
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([delete_house_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data


func create_campaign(house_pda:Pubkey,house_currency:Pubkey,campaign_name:String,reward_mint:Pubkey,collection:Pubkey,fund_amount_lamports:int,max_reward_lamports:int,player_claim_fee:int,timespan:Dictionary,nft_config=null,token_config=null) -> TransactionData:
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(campaign_name,house_pda)
	var signer_payment_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),house_currency)
	var reward_depositor_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),reward_mint)
	
	var create_campaign_ix:Instruction = program.build_instruction("createCampaignUnmanaged",[	
		SolanaService.wallet.get_kp(),
		campaign_pda,
		house_pda,
		signer_payment_account,
		reward_mint,
		ClubhousePDA.get_house_currency_vault(house_pda),
		reward_depositor_account,
		ClubhousePDA.get_campaign_vault_pda(campaign_pda),
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],{
			"collectionPubkey":collection,
			"campaignName":campaign_name,
			"fundAmount":fund_amount_lamports,
			"maxRewardsPerGame":max_reward_lamports,
			"playerClaimPrice":player_claim_fee,
			"timespan":timespan,
			"nftEnergyConfig":AnchorProgram.option(nft_config),
			"tokenEnergyConfig":AnchorProgram.option(token_config)
		})
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([create_campaign_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	
func close_campaign(house_pda:Pubkey,campaign_name:String,reward_mint:Pubkey) -> TransactionData:
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(campaign_name,house_pda)
	
	var close_campaign_ix:Instruction = program.build_instruction("closeCampaignUnmanaged",[	
		campaign_pda,
		SolanaService.wallet.get_kp(),
		reward_mint,
		ClubhousePDA.get_campaign_vault_pda(campaign_pda),
		house_pda,
		SolanaService.wallet.get_kp(),
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],null)
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([close_campaign_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	
	
func start_game(house_pda:Pubkey,campaign_pda:Pubkey,player_nft:Pubkey) -> TransactionData:
	var campaign_player_pda:Pubkey = ClubhousePDA.get_campaign_player_pda(campaign_pda,player_nft)
	var player_nft_token_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),player_nft)
	print(player_nft_token_account.to_string())
	print(ClubhousePDA.get_nft_metadata_pda(player_nft).to_string())
	
	var start_game_ix:Instruction = program.build_instruction("startGameWithNft",[
		house_pda,	
		campaign_pda,
		campaign_player_pda,
		player_nft_token_account,
		ClubhousePDA.get_nft_metadata_pda(player_nft),
		SolanaService.wallet.get_kp(),
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],null)
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([start_game_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	

func claim_reward(house_pda:Pubkey,campaign_pda:Pubkey,player_nft:Pubkey,reward_mint:Pubkey,reward_amount:int) -> TransactionData:
	var campaign_player_pda:Pubkey = ClubhousePDA.get_campaign_player_pda(campaign_pda,player_nft)
	var player_nft_token_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),player_nft)
	print(player_nft_token_account.to_string())
	print(ClubhousePDA.get_nft_metadata_pda(player_nft).to_string())
	
	var claim_reward_ix:Instruction = program.build_instruction("endGameWithNft",[
		house_pda,	
		campaign_pda,
		campaign_player_pda,
		player_nft_token_account,
		ClubhousePDA.get_nft_metadata_pda(player_nft),
		"rewardMint",
		"rewardVault",
		"playerRewardTokenAccount",
		SolanaService.wallet.get_kp(),
		SolanaService.ATA_TOKEN_PID,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],{
			"amountWon":AnchorProgram.u64(reward_amount)
		})
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([claim_reward_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
