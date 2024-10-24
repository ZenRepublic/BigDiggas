extends Node
class_name ScoreCalculatorUI

@onready var animation_player:AnimationPlayer = $AnimationPlayer

@onready var bill_creator:BillCreator = $BillCreator
@onready var item_pedestal:ItemPedestal = $Pedestal
# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.play_song("WinJingle")
	bill_creator.visible=false
	item_pedestal.visible=false
	pass # Replace with function body.

	
func handle_game_end(items_collected:Dictionary) -> void:
	var game_manager:GameManager = get_tree().get_first_node_in_group("GameManager")
	
	animation_player.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	
	item_pedestal.visible=true
	await item_pedestal.showcase_items(items_collected)
	
	bill_creator.visible=true
	bill_creator.generate_bill(items_collected,game_manager.game_mode)
	
func on_replay_button_pressed() -> void:
	get_tree().reload_current_scene()
