extends Node
class_name MintManager

@export var candy_machine_id:String
@export var candy_guard_id:String

@export var minted_amount:Label
@export var progress_bar:ProgressBar

@export var guard_settings:CandyGuardAccessList
@export var mint_tier_selector:MintTierSelector

@export var mint_token_address:String
@export var displayable_token:DisplayableAsset

@export var start_mint_group:String
#first one is default
@export var mint_button:ButtonLock

@export var priority_fee:float=0.0005
@export var fetch_data_on_become_visible:bool=true

@onready var screen_manager:ScreenManager = $ScreenManager

var curr_checkbox:CheckboxLock

var cm_data:CandyMachineData
var mint_group:String

var mint_account:Keypair

signal on_cm_data_fetched

signal on_nft_mint_started
signal on_nft_minted(nft_account:Pubkey)
signal on_nft_mint_failed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mint_group = start_mint_group
		
	if fetch_data_on_become_visible:
		self.visibility_changed.connect(on_visibility_changed)
		
	mint_button.pressed.connect(try_mint)
	pass # Replace with function body.
	
func on_visibility_changed() -> void:
	if self.visible:
		screen_manager.switch_active_panel(0)
		var token_asset:WalletAsset = await SolanaService.asset_manager.get_asset_from_mint(Pubkey.new_from_string(mint_token_address),true,true)
		await displayable_token.set_data(token_asset)
		await fetch_candy_machine_data()
		screen_manager.switch_active_panel(1)
			
func fetch_candy_machine_data() -> void:		
	cm_data = await SolanaService.candy_machine_manager.fetch_candy_machine(Pubkey.new_from_string(candy_machine_id))
	if cm_data!=null:
		update_ui(cm_data)
	
	on_cm_data_fetched.emit()
	

func update_ui(data:CandyMachineData) -> void:
	minted_amount.text = "%s/%s Minted" % [data.items_redeemed,data.items_available]
	progress_bar.value = float(data.items_redeemed)/float(data.items_available)
	update_mint_price()

func try_mint() -> void:
	on_nft_mint_started.emit()
	mint_account = SolanaService.generate_keypair()

	if guard_settings==null:
		push_error("Missing Candy Guard File")
		return
		
	var tx_data:TransactionData = await SolanaService.candy_machine_manager.mint_nft_with_guards(
		Pubkey.new_from_string(candy_machine_id),
		Pubkey.new_from_string(candy_guard_id),
		cm_data,
		SolanaService.wallet,
		SolanaService.wallet.get_kp(),
		guard_settings,
		mint_group,
		TransactionManager.Commitment.FINALIZED,
		priority_fee,
		mint_account
	)
	
	if !tx_data.is_successful():
		on_nft_mint_failed.emit()
		return
		
	cm_data = await SolanaService.candy_machine_manager.fetch_candy_machine(Pubkey.new_from_string(candy_machine_id))
	if cm_data!=null:
		update_ui(cm_data)
		
	if mint_account!=null:	
		var account_pubkey:Pubkey = Pubkey.new_from_bytes(mint_account.get_public_bytes())
		on_nft_minted.emit(account_pubkey)
		mint_account=null

	
#func update_mint_group(selected_checkbox:CheckboxLock) -> void:
	#if curr_checkbox!=null:
		#curr_checkbox.deselect()
		#
	#if !selected_checkbox.button_pressed:
		#curr_checkbox=null
		#mint_group = start_mint_group
	#else:
		#var checkbox_index = checkbox_locks.find(selected_checkbox,0)
		#mint_group = box_mint_groups[checkbox_index]
		#curr_checkbox = selected_checkbox
		#
	#update_mint_price()
	
func get_guard_group_by_name(group_name:String) -> CandyGuardAccessList:
	for group in guard_settings.groups:
		if group.label == group_name:
			return group
	return null
	
func update_mint_price() -> void:
	var guard_group_id:int = await mint_tier_selector.select_mint_tier(displayable_token.asset)
	if guard_group_id == -1:
		mint_button.set_interactable(false)
		return
		
	var group_settings:CandyGuardAccessList = guard_settings.groups[guard_group_id]
	mint_button.token_gate_list[mint_token_address] = group_settings.token_burn_amount / pow(10,2)
	mint_button.token_gate_list[""] = group_settings.sol_payment_lamports / pow(10,9)
	mint_button.try_unlock()
