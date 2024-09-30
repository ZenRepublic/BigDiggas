extends Node
class_name MineInteractor

@onready var screen_manager:ScreenManager = $ScreenManager

@export var mine_account_display:AccountDisplaySystem
@export var mine_card:MineCard

var house_pda:Pubkey

func _ready() -> void:
	var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager")
	house_pda = ClubhousePDA.get_house_pda(menu_manager.house_name)
	
	var filter:Array = [{"memcmp" : { "offset":9, "bytes": house_pda.to_string()}}]
	mine_account_display.set_list(ClubhouseProgram.get_program(),"Campaign","campaignName",filter)
	
	self.visibility_changed.connect(on_visibility_changed)
	mine_account_display.on_account_selected.connect(load_mine_card)
	
	
func on_visibility_changed() -> void:
	if self.visible:
		pass
		
func refresh_mines_list() -> void:
	mine_account_display.refresh_account_list()
		
func load_mine_card(mine_data:Dictionary) -> void:
	screen_manager.switch_active_panel(0)
	await mine_card.set_mine_data(mine_data)
	screen_manager.switch_active_panel(2)
	
func enter_mine() -> void:
	var selected_nft:Pubkey = mine_card.get_selected_digga_nft()
	var campaign_pda:Pubkey = ClubhousePDA.get_campaign_pda(mine_card.curr_selected_mine_data["campaignName"],house_pda)
	#
	#var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager") as MenuManager
	#menu_manager.load_game(mine_card.curr_selected_mine_data,{})
	#
	var tx_data:TransactionData = await ClubhouseProgram.start_game(house_pda,campaign_pda,selected_nft)
	
	if tx_data.is_successful():
		#fetch player campaign account
		var campaign_digga_pda:Pubkey = ClubhousePDA.get_campaign_player_pda(campaign_pda,selected_nft)
		var digga_data:Dictionary =  await SolanaService.fetch_program_account_of_type(ClubhouseProgram.get_program(),"CampaignPlayer",campaign_digga_pda)	
			
		var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager") as MenuManager
		menu_manager.load_game(mine_card.curr_selected_mine_data,digga_data)
	
	
