extends Node
class_name MineInteractor

@onready var screen_manager:ScreenManager = $ScreenManager

@export var mine_account_display:AccountDisplaySystem
@export var mine_card:MineCard

func _ready() -> void:
	await refresh_account_list()
	self.visibility_changed.connect(on_visibility_changed)
	mine_account_display.on_account_selected.connect(load_mine_card)
	
func on_visibility_changed() -> void:
	#if self.visible:
		#await refresh_account_list()
	pass
		
func refresh_account_list() -> void:
	screen_manager.switch_active_panel(0)
	mine_account_display.clear_display()
	var campaigns:Dictionary = await ClubhouseProgram.fetch_all_accounts_of_type("Campaign")
	for key in campaigns.keys():
		var campaign_data:Dictionary = campaigns[key]
		mine_account_display.add_account(campaign_data["campaignName"],campaign_data)
	screen_manager.switch_active_panel(2)

func load_mine_card(mine_data:Dictionary) -> void:
	screen_manager.switch_active_panel(0)
	await mine_card.set_mine_data(mine_data)
	screen_manager.switch_active_panel(3)
	
func enter_mine() -> void:
	var selected_nft:Pubkey = mine_card.digga_details.get_digga_mint()
	
	
