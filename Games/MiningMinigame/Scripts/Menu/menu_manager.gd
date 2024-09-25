extends Node
class_name MenuManager

@export_file(".tscn") var game_scene_path:String

@onready var screen_manager:ScreenManager = $ScreenManager
# Called when the node enters the scene tree for the first time.

func _init() -> void:
	add_to_group("MenuManager")
	
func _ready() -> void:
	MusicManager.play_song("Menu")	
	#var signer = Keypair.new_from_file("res://uthm9E1kt14ZGnMhT6SD16cfXhCRuBCqeHfLo1T7M9s.json")
	#var tx_data:TransactionData = await SolanaService.transaction_manager.transfer_sol("84pL2GAuv8XGVPyZre2xcgUNSGz9csYHBt5AW4PUcEe9",0.01,TransactionManager.Commitment.CONFIRMED,0.0,signer)
	
func play_ui_sound(sound_name:String) -> void:
	MusicManager.play_sound(sound_name)
	
func _on_training_button_pressed() -> void:
	MusicManager.play_sound("ButtonSimple")
	SceneManager.load_scene(game_scene_path,true,-1,{"GameMode":GameManager.GameMode.TRAINING})
	
func _on_mint_button_pressed() -> void:
	MusicManager.play_sound("ButtonRich")
	screen_manager.switch_active_panel(1)
	
func _on_mint_manager_button_pressed() -> void:
	MusicManager.play_sound("ButtonSimple")
	screen_manager.switch_active_panel(2)
	
func _on_admin_button_pressed() -> void:
	MusicManager.play_sound("ButtonRich")
	screen_manager.switch_active_panel(3)
