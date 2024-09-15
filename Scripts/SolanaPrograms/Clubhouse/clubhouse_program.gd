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
		
func fetch_all_accounts_of_type(account_type:String,filter:Array=[]) -> Dictionary:
	program.fetch_all_accounts(account_type,filter)
	var accounts:Dictionary = await program.accounts_fetched
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


func create_campaign() -> TransactionData:
	
	var create_house_ix:Instruction = program.build_instruction("createCampaignUnmanaged",[	
		
		],{
			
		})
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
