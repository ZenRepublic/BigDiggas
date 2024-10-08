extends Node
class_name LoginManager

@export_file(".tscn") var scene_path:String
@export_file(".tscn") var game_scene_path:String
@export var wallet_adapter_ui:WalletAdapterUI
#@onready var login_overlay = $LoginOverlay
@onready var signing_overlay:Control = $SigningOverlay
@onready var animation_player:AnimationPlayer = $AnimationPlayer

@onready var secret_code_input:SecretCodeInput = $SecretCodeInput

var adapter_instance:WalletAdapterUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_song("Login")
	
	signing_overlay.visible=false
	SolanaService.wallet.on_login_begin.connect(pop_adapter)	
	SolanaService.wallet.on_login_finish.connect(confirm_login)	
	
	wallet_adapter_ui.on_provider_selected.connect(process_adapter_result)
	wallet_adapter_ui.on_adapter_cancel.connect(cancel_login)
	
	secret_code_input.on_code_entered.connect(launch_game_secret)
	

func _on_connect_button_pressed() -> void:
	#if generated wallet option, it will just login, if not, it will trigger on_login_begin
	MusicManager.play_sound("ButtonJuicy")
	animation_player.play("login_zoom")
	animation_player.animation_finished.connect(initiate_login,CONNECT_ONE_SHOT)
	
func initiate_login(_finished_anim:String) -> void:
	SolanaService.wallet.try_login()
	
func pop_adapter()-> void:
	wallet_adapter_ui.setup(SolanaService.wallet.wallet_adapter.get_available_wallets())
	wallet_adapter_ui.visible=true
	
func process_adapter_result(provider_id:int) -> void:
	SolanaService.wallet.login_adapter(provider_id)

func cancel_login()-> void:
	signing_overlay.visible=false
	wallet_adapter_ui.visible=false
	animation_player.play_backwards("login_zoom")
	pass
	
func confirm_login(login_success:bool) -> void:
	signing_overlay.visible=false
	wallet_adapter_ui.visible=false
	if login_success:
		SceneManager.load_scene(scene_path,false)

func launch_game_secret(_code_entered:String)-> void:
	SceneManager.load_scene(game_scene_path,true,-1,{"GameMode":GameManager.GameMode.REPLAYING})
