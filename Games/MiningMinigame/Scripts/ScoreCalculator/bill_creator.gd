extends Control
class_name BillCreator

@export var bill_slot_scn:PackedScene
@export var mine_reward_claimer:MineRewardClaimer

@onready var bill_container:VBoxContainer = $BillContainer
@onready var spacer:HBoxContainer = $Spacer

@onready var claim_container:Control = $ClaimContainer
@onready var final_price_label:Label = $ClaimContainer/FinalPrice
@onready var final_price_visual:TextureRect = $ClaimContainer/Visual
@onready var action_button:Button = $ClaimContainer/ActionButton
@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer
var bill_slots:Array[BillSlot]

var final_score:int

func _ready() -> void:
	spacer.visible=false
	action_button.visible=false
	claim_container.visible = false
	
func generate_bill(collected_items:Dictionary,game_mode:GameManager.GameMode) -> void:
	setup_action_button(game_mode)
	
	var token_unit_price:float = 1.0
	var token_texture:Texture2D = null
	
	if game_mode == GameManager.GameMode.MINING:
		token_unit_price = mine_reward_claimer.get_token_unit_price(false)
		token_texture = mine_reward_claimer.get_reward_token_texture()
		
	final_price_visual.texture = token_texture
		
	for key in collected_items.keys():
		var slot_instance:BillSlot = bill_slot_scn.instantiate()
		bill_container.add_child(slot_instance)
		bill_slots.append(slot_instance)
		await slot_instance.setup(self,collected_items[key],token_unit_price,token_texture)	
	
	await get_tree().create_timer(0.3).timeout
	spacer.visible = true
	var spacer_line:Control = spacer.get_child(1)
	spacer_line.size_flags_stretch_ratio=0
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(spacer_line,"size_flags_stretch_ratio",1.0,0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	final_price_label.text = ""
	claim_container.visible = true
	
	var total_value:float=0.0
	
	for slot in bill_slots:
		final_score += slot.get_total_value()
		
	#gotta clamp the reward so user doesn't get more than maximum allowed	
	if game_mode == GameManager.GameMode.MINING:
		final_score = mine_reward_claimer.get_token_value(final_score,false)
		
	for slot in bill_slots:
		var transfer_rate = round(slot.total_value/10)
		var slot_value:float = slot.get_total_value()
		var final_claim_amount:float
		while slot_value>0:
			slot_value -= transfer_rate
			if slot_value < 0:
				slot_value=0
			slot.token_value_label.text = str(slot_value)
			final_claim_amount += transfer_rate
			final_price_label.text = str(final_claim_amount)
			play_increment_sound(lerp(1.0,1.4,final_claim_amount/total_value))
			await get_tree().create_timer(0.05).timeout
			
	await get_tree().create_timer(0.3).timeout
	action_button.visible=true
	
func play_increment_sound(pitch:float) -> void:
	audio_player.pitch_scale = pitch
	audio_player.play()
	
func setup_action_button(game_mode:GameManager.GameMode) -> void:
	match game_mode:
		GameManager.GameMode.TRAINING:
			action_button.text = "Return"
			action_button.pressed.connect(return_to_menu)
		GameManager.GameMode.REPLAYING:
			action_button.text = "Replay"
			action_button.pressed.connect(replay_game)
		GameManager.GameMode.MINING:
			action_button.text = "Claim"
			action_button.pressed.connect(try_claim_reward)
	
		
func return_to_menu() -> void:
	MusicManager.play_sound("ButtonJuicy")
	action_button.disabled = true
	var game_manager:GameManager = get_tree().get_first_node_in_group("GameManager")
	game_manager.return_to_menu()
	
func replay_game() -> void:
	MusicManager.play_sound("ButtonJuicy")
	action_button.disabled = true
	SceneManager.reload_scene()
	
func try_claim_reward() -> void:
	MusicManager.play_sound("ButtonJuicy")
	action_button.disabled = true
	var tx_data:TransactionData = await mine_reward_claimer.claim_reward(final_score)
	
	if tx_data.is_successful():
		var game_manager:GameManager = get_tree().get_first_node_in_group("GameManager")
		game_manager.return_to_menu()
	else:
		action_button.disabled = false
	
