extends Node

var WRAPPED_SOL_ADDRESS:String = "So11111111111111111111111111111111111111112"

@export var jupiter_api:JupiterAPI
@export var token_selector:AssetSelector
@export var input_field_system:InputFieldSystem
@export var sol_swap_value_label:Label
@export var swap_button:Button
@export var swap_slippage_percentage:float = 0.01

@export var refresh_quote:bool = true
@export var quote_refresh_seconds:float = 15

@export var verification_icon:TextureRect
@export var verified_icon:Texture2D
@export var unknown_icon:Texture2D

var curr_token_to_swap:Token
var swap_quote:Dictionary

var time_to_refresh_quote:float = 0

func _ready() -> void:
	swap_button.disabled=true
	input_field_system.on_fields_updated.connect(update_button_state)
	token_selector.on_selected.connect(handle_token_select)
	swap_button.pressed.connect(swap_tokens)
	
	sol_swap_value_label.text = "..."
	
func _process(delta: float) -> void:
	if !refresh_quote:
		return
	
	if !swap_button.disabled:
		time_to_refresh_quote -= delta
		swap_button.text = "Swap (%s)" % str(ceil(time_to_refresh_quote))
		if time_to_refresh_quote <= 0:
			await refresh_swap_quote()
			return

func handle_token_select(selected_asset:Token) -> void:
	verification_icon.visible=false
	
	if selected_asset == curr_token_to_swap:
		return
	curr_token_to_swap = selected_asset
	input_field_system.clear_fields()
	input_field_system.input_fields[0].max_value = await curr_token_to_swap.get_balance()
	
	verification_icon.texture = await set_token_verification_mark(selected_asset.mint)
	verification_icon.visible=true
		
	update_button_state()
	
func set_token_verification_mark(token_mint:Pubkey) -> Texture2D:
	var token_status:JupiterAPI.TokenStatus = await jupiter_api.get_token_status(token_mint)
	match token_status:
		JupiterAPI.TokenStatus.VERIFIED:
			return verified_icon
		JupiterAPI.TokenStatus.UNKNOWN:
			return unknown_icon
	
	return null
	
func update_button_state() -> void:
	var all_fields_valid:bool = true
	
	if !input_field_system.get_inputs_valid():
		all_fields_valid=false
		
	if token_selector.selected_asset == null:
		all_fields_valid=false
		
	if !all_fields_valid:
		swap_button.disabled = true
		sol_swap_value_label.text = "..."
		return
		
	await refresh_swap_quote()
	
func refresh_swap_quote() -> void:
	freeze_selection(true)
	swap_button.text = "Loading..."
	
	var token_to_send:Pubkey = curr_token_to_swap.mint
	var token_to_receive:Pubkey = Pubkey.new_from_string(WRAPPED_SOL_ADDRESS)
	var amount_to_swap:float = input_field_system.get_fields_data()[0]
	
	swap_quote = await jupiter_api.get_swap_quote(token_to_send,token_to_receive,amount_to_swap,swap_slippage_percentage)
	
	sol_swap_value_label.text = str(float(swap_quote["outAmount"]) / pow(10,9))
	time_to_refresh_quote = quote_refresh_seconds
	freeze_selection(false)
	print(swap_quote)
	
	
func freeze_selection(freeze:bool) -> void:
	swap_button.disabled=freeze
	input_field_system.input_fields[0].editable=!freeze
	token_selector.displayable_asset.select_button.disabled=freeze
		
func swap_tokens() -> void:
	if swap_quote == null:
		return
		
	var tx_data:TransactionData = await jupiter_api.swap_token(SolanaService.wallet.get_pubkey(),swap_quote)
	var selected_token:Token = token_selector.selected_asset as Token
	await selected_token.refresh_balance()
	
