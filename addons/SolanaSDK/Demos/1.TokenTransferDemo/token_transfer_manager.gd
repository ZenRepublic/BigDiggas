extends Node
enum TokenType{SOL, SPL}

@export var input_field_system:InputFieldSystem
@export var token_type:TokenType
@export var send_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	send_button.disabled=true
	input_field_system.on_fields_updated.connect(update_button_state)
	send_button.pressed.connect(transfer_tokens)
	
func update_button_state() -> void:
	send_button.disabled = !input_field_system.get_inputs_valid()
	
func transfer_tokens() -> void:
	if !input_field_system.get_inputs_valid():
		return
		
	var input_data:Dictionary= input_field_system.get_fields_data()
	
	match token_type:
		TokenType.SOL:
			var receiver = input_data["receiverAddress"]
			var amount = input_data["transferAmount"]
			var tx_data:TransactionData = await SolanaService.transaction_manager.transfer_sol(receiver,amount)
			if tx_data.is_successful():
				input_field_system.clear_fields()
		TokenType.SPL:
			var token_address = input_data["tokenAddress"]
			var receiver = input_data["receiverAddress"]
			var amount = input_data["transferAmount"]
			var tx_data:TransactionData = await SolanaService.transaction_manager.transfer_token(token_address,receiver,amount)
			if tx_data.is_successful():
				input_field_system.clear_fields()
		
