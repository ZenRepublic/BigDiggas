extends Node

@export var nft_displayer:DisplayableNFT
@export var inspect_button:LinkedButton
@export var screen_manager:ScreenManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func display_minted_nft(nft_account: Pubkey) -> void:
	inspect_button.link = SolanaService.account_inspector.get_account_link(nft_account)
	var nft:Nft = await SolanaService.asset_manager.get_asset_from_mint(nft_account,true)
	await nft_displayer.set_data(nft)
	
	screen_manager.switch_active_panel(3)
	pass # Replace with function body.
