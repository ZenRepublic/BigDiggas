extends Node
class_name MineInteractor

@onready var screen_manager:ScreenManager = $ScreenManager

@export var mine_account_display:AccountDisplaySystem
@export var mine_card:MineCard

var house_pda:Pubkey

func _ready() -> void:
	var menu_manager:MenuManager = get_tree().get_first_node_in_group("MenuManager")
	house_pda = ClubhousePDA.get_house_pda(menu_manager.house_name)
	
	await refresh_mines_list()
	self.visibility_changed.connect(on_visibility_changed)
	mine_account_display.on_account_selected.connect(load_mine_card)
	
	
func on_visibility_changed() -> void:
	if self.visible:
		await refresh_mines_list()
		
func refresh_mines_list() -> void:
	screen_manager.switch_active_panel(0)
	var filter:Array = [{"memcmp" : { "offset":8, "bytes": house_pda.to_string()}}]
	await mine_account_display.refresh_list("Campaign","campaignName",filter)
	screen_manager.switch_active_panel(2)
		
func load_mine_card(mine_data:Dictionary) -> void:
	screen_manager.switch_active_panel(0)
	await mine_card.set_mine_data(mine_data)
	screen_manager.switch_active_panel(3)
	
func enter_mine() -> void:
	var selected_nft:Pubkey = mine_card.get_selected_digga_nft()
	
	
