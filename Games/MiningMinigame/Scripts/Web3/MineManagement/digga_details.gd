extends Node
class_name DiggaDetails

@onready var screen_manager:ScreenManager = $ScreenManager
@export var displayable_digga:DisplayableAsset
@export var energy_bar:ProgressBar
@export var energy_bar_label:Label

@export var enter_mine_button:BaseButton

var digga_nft:Nft;
# Called when the node enters the scene tree for the first time.

func set_digga(nft:Nft, max_energy:int, player_data:Dictionary) -> void:
	digga_nft = nft
	await displayable_digga.set_data(nft)
	
	energy_bar.max_value = max_energy
	
	if player_data.size() != 0:
		energy_bar.value = player_data["energy"]
	else:
		energy_bar.value = max_energy
		
	energy_bar_label.text = "%s/%s" % [energy_bar.value,energy_bar.max_value]
	
	enter_mine_button.disabled = (energy_bar.value <= 0)
	print(player_data)
	
func get_digga_mint() -> Pubkey:
	return digga_nft.mint
	
	
