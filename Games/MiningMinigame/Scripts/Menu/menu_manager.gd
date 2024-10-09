extends Node
class_name MenuManager

@export_file(".tscn") var game_scene_path:String

@export var house_id:String
var house_data:Dictionary

@onready var screen_manager:ScreenManager = $ScreenManager

signal on_house_data_loaded(data:Dictionary)
# Called when the node enters the scene tree for the first time.

func _init() -> void:
	add_to_group("MenuManager")
	
func _ready() -> void:
	MusicManager.play_song("Menu")	
	#C:\Users\thomas\Desktop\kp\dev2gUnXyMLh6WyV9NTBaXeNfo1DTn2R4b69VTGNidF.json
	#var result:Dictionary = await SolanaService.fetch_all_program_accounts_of_type(ClubhouseProgram.get_program(),"House",[])
	#print(result)
	load_house_data()
	
func load_house_data() -> void:
	var house_key:Pubkey = Pubkey.new_from_string(house_id)
	house_data = await SolanaService.fetch_program_account_of_type(ClubhouseProgram.get_program(),"House",house_key)
	if house_data.size() > 0:
		on_house_data_loaded.emit(house_data)
		print(house_data)
	else:
		print("FAILED TO FETCH HOUSE DATA!!")
	
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
	
func load_game(mine_data:Dictionary,digga_data:Dictionary) -> void:
	MusicManager.play_sound("ButtonSimple")
	SceneManager.load_scene(game_scene_path,true,-1,{
		"GameMode":GameManager.GameMode.MINING,
		"HouseData":house_data,
		"MineData":mine_data,
		"DiggaData":digga_data
		})
