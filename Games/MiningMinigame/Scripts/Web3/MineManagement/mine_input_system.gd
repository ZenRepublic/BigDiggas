extends DataInputSystem
class_name MineInputSystem

@export var token_selector:AssetSelector
@export var manager_selector:AssetSelector

@export var fund_input_field:InputField
@export var max_fund_button:Button

@export var token_visuals:Array[TextureRect]

@export var fee_explanation:Label
@export var creation_fee_label:Label

var selected_token:Token

var mine_creation_fee:float
var manager_creation_fee:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	max_fund_button.pressed.connect(set_max_fund)	
	token_selector.on_selected.connect(set_mine_token)
	manager_selector.on_selected.connect(update_manager_selection)
	pass # Replace with function body.
	
func setup(house_data:Dictionary) -> void:
	var house_config:Dictionary = house_data["config"]
	var decimals = await SolanaService.get_token_decimals(house_data["houseCurrency"].to_string())
	mine_creation_fee = house_config["campaignCreationFee"]/pow(10,decimals)
	manager_creation_fee = (house_config["campaignCreationFee"]-house_config["campaignManagerDiscount"])/pow(10,decimals)
	update_manager_selection(null)
	
	var claim_tax_percentage:float = house_config["rewardsTax"]/10.0
	fee_explanation.text = "*Fees claimable after campaign has finished. House Tax of %s%% is applied!" % str(claim_tax_percentage)
	
func handle_fields_updated() -> void:
	input_submit_button.disabled = !get_inputs_valid()
	
func set_max_fund() -> void:
	fund_input_field.text = str(fund_input_field.max_value)
	
func set_mine_token(selected_asset:WalletAsset) -> void:
	var new_token:Token = selected_asset as Token

	if new_token != selected_token:
		fund_input_field.clear()
	
	selected_token = new_token
	fund_input_field.max_value = await selected_token.get_balance()
	
	if selected_token.image!=null:
		for visual in token_visuals:
			visual.texture = selected_token.image

	handle_fields_updated()
	
func update_manager_selection(selected_nft:Nft) -> void:
	if selected_nft == null:
		creation_fee_label.text = "%s SOL" % str(mine_creation_fee)
		return
	
	var manager_fee_text:String = "FREE" if manager_creation_fee==0 else "%s SOL" % str(manager_creation_fee)
	creation_fee_label.text = manager_fee_text
