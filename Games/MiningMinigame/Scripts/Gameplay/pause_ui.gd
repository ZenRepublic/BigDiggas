extends Control
class_name PauseUI

@onready var pause_screen:Control = $Content
var player_manager:PlayerManager

func _ready() -> void:
	player_manager = get_tree().get_first_node_in_group("Player")
	player_manager.input_handler.on_escape.connect(handle_pause_state)
	pause_screen.visible=false

func handle_pause_state() -> void:
	if !pause_screen.visible:
		show_pause_screen()
	else:
		resume_game()
			
func show_pause_screen() -> void:
	pause_screen.visible=true
	player_manager.input_handler.show_mouse(true)

func resume_game() -> void:
	pause_screen.visible=false
	player_manager.input_handler.show_mouse(false)
	
func end_run() -> void:
	player_manager.input_handler.show_mouse(false)
	player_manager.input_handler.input_enabled=false
	var game_manager:GameManager = get_tree().get_first_node_in_group("GameManager")
	game_manager.end_game()
#	after run is ended, no longer gonna need UI. might as well queuefree. in play again scenario, reloaded scene anyway
	queue_free()
