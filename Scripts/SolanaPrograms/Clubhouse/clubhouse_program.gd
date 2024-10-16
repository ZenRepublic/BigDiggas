extends Node

#for building custom program instructions, first goes function name, then array of accounts
#and then variables to pass in

#IMPORTANT:
#if no variables need to be passed in, write 'null'
#if multiple variables, put them in a dictionary
#if the variable is a class, pass it in as dictionary

@onready var program:AnchorProgram = $AnchorProgram
@export var oracle_signer:OracleSigner

func get_program() -> AnchorProgram:
	return program
	
func get_pid() -> Pubkey:
		return Pubkey.new_from_string(program.get_pid())
		
func send_transaction(instructions:Array[Instruction], oracle:Pubkey=null) -> TransactionData:
	var tx_data:TransactionData
	
	if oracle!=null and oracle.to_string() != SystemProgram.get_pid().to_string():
		if oracle_signer == null:
			push_error("Oracle Signer is needed for this transaction, but the reference is missing!")
			return TransactionData.new({})
		
		#First we sign with the user		
		var signers:Array = [SolanaService.wallet.get_kp(),oracle]
		var transaction:Transaction = await SolanaService.transaction_manager.create_transaction(instructions,SolanaService.wallet.get_kp())
		transaction = await SolanaService.transaction_manager.sign_transaction_normal(transaction,signers)
		
		#get the signature from oracle. it returns tx_bytes. so turn to transaction again 		
		var tx_bytes:PackedByteArray = await oracle_signer.add_oracle_signature(transaction)
		transaction.queue_free()

		if tx_bytes.size()==0:
			push_error("Failed to sign with the oracle keypair!")
			return TransactionData.new({})
			
		var signed_transaction:Transaction = Transaction.new_from_bytes(tx_bytes)
		add_child(signed_transaction)
		signed_transaction.set_signers(signers)
		tx_data = await SolanaService.transaction_manager.send_transaction(signed_transaction,TransactionManager.Commitment.PROCESSED)
	else:
		var transaction:Transaction = await SolanaService.transaction_manager.create_transaction(instructions,SolanaService.wallet.get_kp())
		tx_data = await SolanaService.transaction_manager.sign_and_send(transaction)
		
	return tx_data
		
func create_house(house_name:String,manager_collection:Pubkey,house_currency:Pubkey,house_config:Dictionary) -> TransactionData:
	var create_house_ix:Instruction = get_create_house_instruction(house_name,manager_collection,house_currency,house_config)
	var tx_data:TransactionData = await send_transaction([create_house_ix])
	return tx_data
		
func get_create_house_instruction(house_name:String,manager_collection:Pubkey,house_currency:Pubkey,house_config:Dictionary) -> Instruction:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)
	var ix:Instruction = program.build_instruction("createHouse",[
		SolanaService.wallet.get_kp(),
		ClubhousePDA.get_program_admin_pda(SolanaService.wallet.get_pubkey()),
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
	return ix
	
func update_house(house_name:String,house_config:Dictionary) -> TransactionData:
	var update_house_ix:Instruction = get_update_house_instruction(house_name,house_config)
	var tx_data:TransactionData = await send_transaction([update_house_ix])
	return tx_data
	
func get_update_house_instruction(house_name:String,house_config:Dictionary) -> Instruction:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)
	
	var ix:Instruction = program.build_instruction("updateHouse",[
		house_pda,
		SolanaService.wallet.get_kp(),
	],{
		"houseConfig": house_config,
	})
	return ix
	
func close_house(house_name:String, house_currency:Pubkey) -> TransactionData:
	var close_house_ix:Instruction = get_close_house_instruction(house_name,house_currency)
	var tx_data:TransactionData = await send_transaction([close_house_ix])
	return tx_data
	
func get_close_house_instruction(house_name:String, house_currency:Pubkey) -> Instruction:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)
	var fees_withdrawal_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),house_currency)
	
	var ix:Instruction = program.build_instruction("closeHouse",[
		house_pda,
		SolanaService.wallet.get_kp(),
		ClubhousePDA.get_house_currency_vault(house_pda),
		fees_withdrawal_account,
		house_currency,
		SolanaService.ATA_TOKEN_PID,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
	],null)
	return ix
	
func withdraw_house_fees(house_name:String, house_currency:Pubkey) -> TransactionData:
	var withdraw_house_fees_ix:Instruction = get_withdraw_house_fees_instruction(house_name,house_currency)
	var tx_data:TransactionData = await send_transaction([withdraw_house_fees_ix])
	return tx_data
	
func get_withdraw_house_fees_instruction(house_name:String, house_currency:Pubkey) -> Instruction:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name)
	var fees_withdrawal_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),house_currency)
	
	var ix:Instruction = program.build_instruction("withdrawHouseFees",[
		house_pda,
		SolanaService.wallet.get_kp(),
		ClubhousePDA.get_house_currency_vault(house_pda),
		fees_withdrawal_account,
		house_currency,
		SolanaService.ATA_TOKEN_PID,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
	],null)
	return ix

func create_campaign(house_pda:Pubkey,house_currency:Pubkey,campaign_name:String,reward_mint:Pubkey,fund_amount_lamports:int,max_reward_lamports:int,player_claim_fee:int,timespan:Dictionary,nft_config=null,token_config=null) -> TransactionData:
	var create_campaign_ix:Instruction = get_create_campaign_instruction(house_pda,house_currency,campaign_name,reward_mint,fund_amount_lamports,max_reward_lamports,player_claim_fee,timespan,nft_config,token_config)
	var tx_data:TransactionData = await send_transaction([create_campaign_ix])
	return tx_data

func get_create_campaign_instruction(house_pda:Pubkey,house_currency:Pubkey,campaign_name:String,reward_mint:Pubkey,fund_amount_lamports:int,max_reward_lamports:int,player_claim_fee:int,timespan:Dictionary,nft_config=null,token_config=null) -> Instruction:
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(campaign_name,house_pda)
	var creation_fee_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),house_currency)
	var reward_depositor_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),reward_mint)
	
	var ix:Instruction = program.build_instruction("createCampaign",[	
		SolanaService.wallet.get_kp(),
		campaign_pda,
		house_pda,
		creation_fee_account,
		reward_mint,
		ClubhousePDA.get_house_currency_vault(house_pda),
		reward_depositor_account,
		ClubhousePDA.get_campaign_vault_pda(campaign_pda),
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],{
			"campaignName":campaign_name,
			"fundAmount":AnchorProgram.u64(fund_amount_lamports),
			"maxRewardsPerGame":AnchorProgram.u64(max_reward_lamports),
			"playerClaimPrice":AnchorProgram.u64(player_claim_fee),
			"timespan":timespan,
			"nftConfig":AnchorProgram.option(nft_config),
			"tokenConfig":AnchorProgram.option(token_config)
		})
	return ix
	
func close_campaign(house_pda:Pubkey,campaign_name:String,reward_mint:Pubkey) -> TransactionData:
	var close_campaign_ix:Instruction = get_close_campaign_instruction(house_pda,campaign_name,reward_mint)
	var tx_data:TransactionData = await send_transaction([close_campaign_ix])
	return tx_data
	
func get_close_campaign_instruction(house_pda:Pubkey,campaign_name:String,reward_mint:Pubkey) -> Instruction:
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(campaign_name,house_pda)
	var reward_withdrawal_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),reward_mint)
	
	var ix:Instruction = program.build_instruction("closeCampaign",[	
		campaign_pda,
		reward_withdrawal_account,
		reward_mint,
		ClubhousePDA.get_campaign_vault_pda(campaign_pda),
		house_pda,
		SolanaService.wallet.get_kp(),
		SolanaService.ATA_TOKEN_PID,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],null)
	return ix
	
func start_game(house_pda:Pubkey,oracle:Pubkey,campaign_pda:Pubkey,player_nft:Pubkey,reward_mint:Pubkey,force_end_previous_game:bool) -> TransactionData:
	var instructions:Array[Instruction]
	
	var start_game_ix:Instruction = get_start_game_instruction(house_pda,campaign_pda,player_nft)
	instructions.append(start_game_ix)
	
	var tx_data:TransactionData
	
	if force_end_previous_game:
		var end_game_ix:Instruction = get_claim_reward_instruction(house_pda,oracle,campaign_pda,player_nft,reward_mint,0)
		instructions.insert(0,end_game_ix)
		tx_data = await send_transaction(instructions,oracle)
	else:
		tx_data = await send_transaction(instructions)
		
	return tx_data
	
func get_start_game_instruction(house_pda:Pubkey,campaign_pda:Pubkey,player_nft:Pubkey) -> Instruction:
	var campaign_player_pda:Pubkey = ClubhousePDA.get_campaign_player_pda(campaign_pda,player_nft)
	var player_nft_token_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),player_nft)
	
	var ix:Instruction = program.build_instruction("startGameWithNft",[
		house_pda,	
		campaign_pda,
		campaign_player_pda,
		player_nft_token_account,
		ClubhousePDA.get_nft_metadata_pda(player_nft),
		SolanaService.wallet.get_kp(),
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],null)
	return ix
	
	
func claim_reward(house_pda:Pubkey,oracle:Pubkey,campaign_pda:Pubkey,player_nft:Pubkey,reward_mint:Pubkey,reward_amount:int) -> TransactionData:
	var claim_reward_ix:Instruction = get_claim_reward_instruction(house_pda,oracle,campaign_pda,player_nft,reward_mint,reward_amount)
	var tx_data:TransactionData = await send_transaction([claim_reward_ix],oracle)
	return tx_data

func get_claim_reward_instruction(house_pda:Pubkey,oracle:Pubkey,campaign_pda:Pubkey,player_nft:Pubkey,reward_mint:Pubkey,reward_amount:int) -> Instruction:
	var campaign_player_pda:Pubkey = ClubhousePDA.get_campaign_player_pda(campaign_pda,player_nft)
	var player_nft_token_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),player_nft)

	var player_reward_token_account:Pubkey = Pubkey.new_associated_token_address(SolanaService.wallet.get_pubkey(),reward_mint)
	
	#if oracle is not set, it is defaulted to SystemProgram. We set it to null then to not need a signer	
	if oracle!=null and oracle.to_string() == SystemProgram.get_pid().to_string():
		oracle = null
		
	var ix:Instruction = program.build_instruction("endGameWithNft",[
		house_pda,	
		campaign_pda,
		campaign_player_pda,
		player_nft_token_account,
		ClubhousePDA.get_nft_metadata_pda(player_nft),
		reward_mint,
		ClubhousePDA.get_campaign_vault_pda(campaign_pda),
		player_reward_token_account,
		SolanaService.wallet.get_kp(),
		oracle,
		SolanaService.ATA_TOKEN_PID,
		SolanaService.TOKEN_PID,
		SystemProgram.get_pid()
		],{
			"amountWon":AnchorProgram.u64(reward_amount)
		})
	return ix
