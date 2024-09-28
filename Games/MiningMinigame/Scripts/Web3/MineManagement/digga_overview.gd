extends Node
class_name DiggaOverview

@onready var screen_manager:ScreenManager = $ScreenManager
@export var displayable_digga:DisplayableAsset
@export var energy_bar:ProgressBar
@export var energy_bar_label:Label

@export var enter_mine_button:BaseButton

var digga_nft:Nft;

var selection_locked:bool=false
# Called when the node enters the scene tree for the first time.

func set_digga(nft:Nft, mine_data:Dictionary, player_data:Dictionary) -> void:
	screen_manager.switch_active_panel(2)
	digga_nft = nft
	var max_energy:int = mine_data["nftConfig"]["maxPlayerEnergy"]
	await displayable_digga.set_data(nft)
	
	energy_bar.max_value = max_energy
	
	#data may be empty if going to mine for the first time	
	if player_data.size() != 0:
		energy_bar.value = player_data["energy"]
	else:
		energy_bar.value = max_energy
		
	energy_bar_label.text = "%s/%s" % [energy_bar.value,energy_bar.max_value]
	
	enter_mine_button.disabled = (energy_bar.value <= 0)
	
func get_digga_nft() -> Pubkey:
	return digga_nft.mint
	
func lock_selection(lock:bool) -> void:
	selection_locked = lock
	
	if lock:
		screen_manager.switch_active_panel(1)
	else:
		screen_manager.switch_active_panel(0)
		
	
func is_locked() -> bool: return selection_locked
