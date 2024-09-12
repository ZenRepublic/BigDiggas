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
	
	var oracle = Pubkey.new_from_string("uthm9E1kt14ZGnMhT6SD16cfXhCRuBCqeHfLo1T7M9s")
	
	await create_hunt("best hunt 2",oracle,test_metadata)
	#print(await get_hunt_data("best hunt"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_hunt(hunt_name:String,oracle:Pubkey,token_metadata:Dictionary) -> void:
	var hunt_pda:Pubkey = get_hunt_pda(hunt_name)
	var hunt_token_pda:Pubkey = get_hunt_token_pda(hunt_pda)
	var hunt_token_metadata_pda:Pubkey = get_hunt_token_metadata_pda(hunt_pda,hunt_token_pda)
	
	var create_hunt_ix:Instruction = program.build_instruction("createTreasury",[
		hunt_pda,
		hunt_token_pda,
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
	
	
func get_hunt_pda(hunt_name:String) -> Pubkey:
	var hunt_seed:PackedByteArray = "hunt".to_utf8_buffer()
	var hunt_name_seed:PackedByteArray = hunt_name.to_utf8_buffer()
	return Pubkey.new_pda_bytes([hunt_seed,hunt_name_seed],Pubkey.new_from_string(program.get_pid()))
	
func get_hunt_token_pda(hunt_pda:Pubkey) -> Pubkey:
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
