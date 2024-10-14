extends Node
class_name DiggaOverview

@onready var screen_manager:ScreenManager = $ScreenManager
@export var displayable_digga:DisplayableAsset
@export var energy_bar:ProgressBar
@export var energy_bar_label:Label
@export var recharge_timed_button:TimedButton

@export var enter_mine_button:BaseButton

var mine_data:Dictionary
var digga_data:Dictionary
var digga_nft:Nft

var selection_locked:bool=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if recharge_timed_button!=null:
		recharge_timed_button.on_timer_finished.connect(display_digga_energy)

func set_digga(nft:Nft, mine_data:Dictionary, player_data:Dictionary) -> void:
	screen_manager.switch_active_panel(2)
	digga_nft = nft
	digga_data = player_data
	self.mine_data = mine_data
	var max_energy:int = mine_data["nftConfig"]["maxPlayerEnergy"]
	energy_bar.max_value = max_energy
	
	await displayable_digga.set_data(nft)

	display_digga_energy()
	
func display_digga_energy() -> void:
	#data may be empty if going to mine for the first time
	if digga_data.size() == 0:
		energy_bar.value = energy_bar.max_value
		recharge_timed_button.visible = false
	elif mine_data["nftConfig"]["energyRechargeMinutes"] == null:
		energy_bar.value = digga_data["energy"]
		recharge_timed_button.visible = false
	else:
		var remaining_energy:int = digga_data["energy"]
		var time_charging:float = Time.get_unix_time_from_system() - digga_data["rechargeStartTime"]
		#timestamps are in seconds, so multiplying minutes should do the job
		var energy_recharge_timestamp:int = mine_data["nftConfig"]["energyRechargeMinutes"] * 60
		var energy_charged:int = floori(time_charging/energy_recharge_timestamp)
		energy_bar.value = clamp(remaining_energy+energy_charged,0,energy_bar.max_value)
		
		recharge_timed_button.visible = energy_bar.value < energy_bar.max_value
		if recharge_timed_button.visible:
			var time_to_next_energy = energy_recharge_timestamp - int(time_charging) % energy_recharge_timestamp
			recharge_timed_button.start_timer(Time.get_unix_time_from_system() + time_to_next_energy)
			
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

func get_data() -> Dictionary:
	if digga_data.size()>0:
		return digga_data
	
	#if there's no data, means fresh account	
	var data:Dictionary = {
		"mint": get_digga_nft(),
		"inGame":false
	}
	return data
