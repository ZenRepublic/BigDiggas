extends Node2D
class_name GameManager

enum GameMode {TRAINING,REPLAYING, MINING}

var player:PlayerManager
@export var game_mode:GameMode
@export var score_calculator_scn:PackedScene
@export var map_manager:MapManager
@export var shockwave_manager:Shockwave
@export var panel_popper:PanelPopper
@export var menu_scene_path:String

func _init():
	add_to_group("GameManager")
# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.play_song("Game")
	
	player = get_tree().get_first_node_in_group("Player")
	player.stats.on_energy_depleted.connect(handle_out_of_energy)
	
	game_mode = SceneManager.get_interscene_data("GameMode")
	pass # Replace with function body.

	
func end_game() -> void:
#	register player to database as alpha user for mystery reward
	RubianServer.register_user(SolanaService.wallet.get_pubkey())
	
	var inventory:Dictionary = player.inventory.get_collected_items()
	player.input_handler.show_mouse(true)
	
	var score_calculator_instance:ScoreCalculatorUI =score_calculator_scn.instantiate()
	add_child(score_calculator_instance)
	score_calculator_instance.handle_game_end(inventory)
	
	
#show a menu popup about runnning out of energy and then trigger end_game
func handle_out_of_energy() -> void:
	#end game can be triggered by player when ran out of energy
	#however, the trigger may be delayed if game manager is handling the item retrieval
	#so check if no items being handled
	#game manager will call to the player to check the energy after items are uncovered anyway
	if items_uncovered.size()>0:
		return
	
	player.freeze(true)
	await panel_popper.pop_panel(0,2.0)
	end_game()
#show a menu popup about uncovering all treasures and then trigger end_game
func handle_all_treasures_uncovered() -> void:
	player.freeze(true)
	await panel_popper.pop_panel(1,2.0)
	end_game()
	

var items_uncovered:Array[MineItem]
var active_item:MineItem=null
func try_handle_next_item() -> void:
	if items_uncovered.size()==0:
		var treasures_remaining:int = map_manager.get_treasures_remaining() 
		if treasures_remaining == 0:
			handle_all_treasures_uncovered()
			return
			
		if player.stats.energy == 0:
			handle_out_of_energy()
			return

		player.freeze(false)
		return
		
	if active_item==null:
		player.freeze(true)
	else:
		return
		
	handle_uncover(items_uncovered[0])
	active_item = items_uncovered[0]
	
func add_item_to_queue(item:MineItem) -> void:
	items_uncovered.append(item)
	try_handle_next_item()
	
func handle_uncover(item:MineItem) -> void:
	active_item = item
	item.uncover()
	item.on_uncover_finished.connect(remove_active_item_from_queue,CONNECT_ONE_SHOT)
	
func remove_active_item_from_queue(item:MineItem) -> void:
	items_uncovered.erase(item)
	item.destroy()
	active_item = null
	try_handle_next_item()
	
func return_to_menu() -> void:
	SceneManager.load_scene(menu_scene_path)
	
