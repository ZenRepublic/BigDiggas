extends Node
class_name MenuManager

@export_file(".tscn") var game_scene_path:String

@onready var screen_manager:ScreenManager = $ScreenManager
# Called when the node enters the scene tree for the first time.

func _init() -> void:
	add_to_group("MenuManager")
	
func _ready() -> void:
	MusicManager.play_song("Menu")	
	
func play_ui_sound(sound_name:String) -> void:
	MusicManager.play_sound(sound_name)
	
func _on_training_button_pressed() -> void:
	MusicManager.play_sound("ButtonSimple")
	SceneManager.load_scene(game_scene_path,true,-1,{"GameMode":GameManager.GameMode.TRAINING})
	
func _on_mint_manager_button_pressed() -> void:
	MusicManager.play_sound("ButtonSimple")
	screen_manager.switch_active_panel(1)
	
func _on_mint_button_pressed() -> void:
	MusicManager.play_sound("ButtonRich")
	screen_manager.switch_active_panel(2)
	