extends Node

@onready var program:AnchorProgram = $AnchorProgram

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test_metadata:Dictionary={
		"name":"TEST TOKEN",
		"symbol":"TTKEN",
		"uri":"",
		"decimals": 0,
	}
	
	#var oracle = Pubkey.new_from_string("uthm9E1kt14ZGnMhT6SD16cfXhCRuBCqeHfLo1T7M9s")
	#var tx_data:TransactionData = await earn_tokens(get_hunt_pda("best hunt 2"),10)
	
	#var balance:float = await get_player_score("best hunt 2")
	#print(balance)
	
	#await create_hunt("best hunt 2",oracle,test_metadata)
	
	#print(await get_hunt_data("best hunt"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_hunt(hunt_name:String,oracle:Pubkey,token_metadata:Dictionary) -> TransactionData:
	var hunt_pda:Pubkey = get_hunt_pda(hunt_name)
	var hunt_token:Pubkey = get_hunt_token(hunt_pda)
	var hunt_token_metadata_pda:Pubkey = get_hunt_token_metadata_pda(hunt_pda,hunt_token)
	
	var create_hunt_ix:Instruction = program.build_instruction("createTreasury",[
		hunt_pda,
		hunt_token,
		hunt_token_metadata_pda,
		SolanaService.wallet.get_kp(),
		SolanaService.SYSVAR_RENT_PUBKEY,
		SystemProgram.get_pid(),
		SolanaService.TOKEN_PID,
		SolanaService.TOKEN_METADATA_PID
	],{
		"name":hunt_name,
		"oracle":oracle,
		"tokenParams":token_metadata
	})
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([create_hunt_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	
func earn_tokens(hunt_pda:Pubkey,amount:float) -> TransactionData:
	var hunt_token:Pubkey = get_hunt_token(hunt_pda)
	var hunt_token_decimals = await SolanaService.get_token_decimals(hunt_token.to_string())
	
	var lamport_amount:int = floor(amount * pow(10,hunt_token_decimals))
	
	
	var oracle:Keypair = Keypair.new_from_file("res://uthm9E1kt14ZGnMhT6SD16cfXhCRuBCqeHfLo1T7M9s.json")
	
	var earn_token_ix:Instruction = program.build_instruction("mintTokens",[
		hunt_pda,
		get_hunt_token(hunt_pda),
		get_hunter_pda(hunt_pda),
		SolanaService.wallet.get_kp(),
		oracle.to_pubkey(),
		SolanaService.SYSVAR_RENT_PUBKEY,
		SystemProgram.get_pid(),
		SolanaService.TOKEN_PID,
	],{
		"quantity":lamport_amount
	})
	
	var transaction:Transaction = await SolanaService.transaction_manager.create_transaction([earn_token_ix])
	var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	return tx_data
	
	
	
func get_hunt_pda(hunt_name:String) -> Pubkey:
	var hunt_seed:PackedByteArray = "hunt".to_utf8_buffer()
	var hunt_name_seed:PackedByteArray = hunt_name.to_utf8_buffer()
	return Pubkey.new_pda_bytes([hunt_seed,hunt_name_seed],Pubkey.new_from_string(program.get_pid()))
	
func get_hunt_token(hunt_pda:Pubkey) -> Pubkey:
	var token_seed:PackedByteArray = "hunt_token".to_utf8_buffer()
	var hunt_pda_bytes:PackedByteArray = hunt_pda.to_bytes()
	return Pubkey.new_pda_bytes([token_seed,hunt_pda_bytes],Pubkey.new_from_string(program.get_pid()))
	
func get_hunt_token_metadata_pda(hunt_pda:Pubkey, hunt_token_pda:Pubkey) -> Pubkey:
	var metadata_seed:PackedByteArray = "metadata".to_utf8_buffer()
	var metadata_pid_seed:PackedByteArray = SolanaUtils.bs58_decode(SolanaService.TOKEN_METADATA_PID)
	var hunt_token_pda_bytes:PackedByteArray = hunt_token_pda.to_bytes()
	return Pubkey.new_pda_bytes([metadata_seed,metadata_pid_seed,hunt_token_pda_bytes],Pubkey.new_from_string(SolanaService.TOKEN_METADATA_PID))
	
func get_hunt_data(hunt_name:String) -> Dictionary:
	program.fetch_account("Treasury",get_hunt_pda(hunt_name))
	var data:Dictionary = await program.account_fetched
	return data
	
func get_hunter_pda(hunt_pda:Pubkey) -> Pubkey:
	var hunter_seed:PackedByteArray = "hunter".to_utf8_buffer()
	var hunt_pda_bytes:PackedByteArray = hunt_pda.to_bytes()
	var player_account_bytes:PackedByteArray = SolanaService.wallet.get_pubkey().to_bytes()
	return Pubkey.new_pda_bytes([hunter_seed,hunt_pda_bytes,player_account_bytes],Pubkey.new_from_string(program.get_pid()))
	
func get_player_score(hunt_name:String) -> float:
	var hunt_pda:Pubkey = get_hunt_pda(hunt_name)
	var hunt_token:Pubkey = get_hunt_token(hunt_pda)
	var player_token_account:Pubkey = get_hunter_pda(hunt_pda)
	
	var balance:float = await SolanaService.get_ata_balance(player_token_account.to_string())
	return balance
	
	
