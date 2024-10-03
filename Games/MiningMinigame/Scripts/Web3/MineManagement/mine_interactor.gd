extends Node
class_name MineInteractor

@onready var screen_manager:ScreenManager = $ScreenManager

@export var mine_account_display:AccountDisplaySystem
@export var mine_card:MineCard

var house_pda:Pubkey

func _ready() -> void:
	var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager")
	menu_manager.on_house_data_loaded.connect(setup_mines)
	
	
func on_visibility_changed() -> void:
	if self.visible:
		pass
		
func setup_mines(house_data:Dictionary) -> void:
	house_pda = ClubhousePDA.get_house_pda(house_data["houseName"])
	
	var filter:Array = [{"memcmp" : { "offset":9, "bytes": house_pda.to_string()}}]
	mine_account_display.set_list(ClubhouseProgram.get_program(),"Campaign","campaignName",filter)
	
	self.visibility_changed.connect(on_visibility_changed)
	mine_account_display.on_account_added.connect(handle_mine_active)
	mine_account_display.on_account_selected.connect(load_mine_card)
	
		
func refresh_mines_list() -> void:
	mine_account_display.refresh_account_list()
		
func load_mine_card(mine_data:Dictionary) -> void:
	screen_manager.switch_active_panel(0)
	await mine_card.set_mine_data(mine_data)
	screen_manager.switch_active_panel(2)

func handle_mine_active(mine_entry:AccountDisplayEntry) -> void:
	var mine_end_timestamp:float = mine_entry.data["timeSpan"]["endTime"]
	var utc_timestamp:float = Time.get_unix_time_from_system()
	mine_entry.button.disabled = utc_timestamp>mine_end_timestamp

func enter_mine() -> void:
	var digga_data:Dictionary = mine_card.get_selected_digga_data()
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(mine_card.curr_selected_mine_data["campaignName"],house_pda)
	var reward_mint:Pubkey = mine_card.curr_selected_mine_data["rewardMint"]
	
	var digga_nft:Pubkey = digga_data["mint"]
	var force_end_previous_game:bool = digga_data["inGame"]
	
	var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager") as MenuManager
	var oracle:Pubkey = menu_manager.house_data["config"]["oracleKey"]
	
	#var instructions:Array[Instruction]
	#if force_end_previous_game:
		#var end_game_ix:Instruction = ClubhouseProgram.get_claim_reward_instruction(house_pda,oracle,campaign_pda,digga_nft,reward_mint,0)
		#instructions.append(end_game_ix)
		#
	#var start_game_ix:Instruction = ClubhouseProgram.get_start_game_instruction(house_pda,campaign_pda,digga_nft)
	#instructions.append(start_game_ix)
	#
	#var transaction:Transaction = await SolanaService.transaction_manager.create_transaction(instructions)
	#transaction.set_payer(SolanaService.wallet.get_kp())
	#transaction.set_signers([SolanaService.wallet.get_kp(),oracle])
	#var oracle_signed_tx:Transaction = await RubianServer.get_oracle_signature(transaction)
	#print(oracle_signed_tx.serialize())
	#var tx_data:TransactionData = await SolanaService.transaction_manager.sign_transaction(transaction)
	
	var tx_data:TransactionData = await ClubhouseProgram.start_game(house_pda,oracle,campaign_pda,digga_nft,reward_mint,force_end_previous_game)
	
	if tx_data.is_successful():
		menu_manager.load_game(mine_card.curr_selected_mine_data,digga_data)
	
	
