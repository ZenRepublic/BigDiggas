extends Node
class_name HouseEditDataHandler

@export var input_field_system:InputFieldSystem
@export var data_submit_button:BaseButton

var decimals:int

func _ready() -> void:
	input_field_system.on_fields_updated.connect(update_button_state)
	data_submit_button.disabled=false

func set_fields(house_data:Dictionary) -> void:
	decimals = await SolanaService.get_token_decimals(house_data["houseCurrency"].to_string())
	input_field_system.get_field("oracleKey").text = house_data["config"]["oracleKey"].to_string()
	input_field_system.get_field("campaignCreationFee").text = str(house_data["config"]["campaignCreationFee"]/pow(10,decimals))
	input_field_system.get_field("campaignManagerDiscount").text = str(house_data["config"]["campaignCreationFee"]/pow(10,decimals) - house_data["config"]["campaignManagerDiscount"]/pow(10,decimals))
	input_field_system.get_field("claimFee").text = str(house_data["config"]["claimFee"]/pow(10,decimals))
	input_field_system.get_field("rewardsTax").text = str(house_data["config"]["rewardsTax"]/10.0)
	pass
	
func update_button_state() -> void:
	var all_fields_valid:bool = true
	
	#	public key fields need to be verified as having 32bytes in base58 encoding
	#only after doing this adjusment (extra check for validity because input system doesnt have support for crypto)
	#we can check for whether all input is valid
	var pubkey_keys:Array[String] = ["oracleKey"]
	for i in pubkey_keys:
		var field:InputField = input_field_system.get_field(i)
		if field.is_optional and field.text == "":
			continue
		if SolanaUtils.bs58_decode(field.text).size() != 32:
			field.clear()
			
			
	if !input_field_system.get_inputs_valid():
		all_fields_valid = false
		
#	manager fee can't be bigger than standard fee
	var input_data:Dictionary = input_field_system.get_fields_data()
	if input_data["campaignManagerDiscount"] > input_data["campaignCreationFee"]:
		input_field_system.get_field("campaignManagerDiscount").clear()
		all_fields_valid=false
		
	data_submit_button.disabled = !all_fields_valid
	
	
func get_data() -> Dictionary:
	var raw_data:Dictionary = input_field_system.get_fields_data()
	var house_data:Dictionary = {
		"oracleKey":pubkey_or_null(raw_data["oracleKey"]) if raw_data["oracleKey"]!=null else null,
		"campaignCreationFee":raw_data["campaignCreationFee"],
		"campaignManagerDiscount":raw_data["campaignCreationFee"] - raw_data["campaignManagerDiscount"],
		"claimFee":raw_data["claimFee"],
		"rewardsTax":raw_data["rewardsTax"]*10
	}
	
	return house_data
	
func pubkey_or_null(address:String) -> Pubkey:
	if address.length() == 0:
		return null
		
	return Pubkey.new_from_string(address)
	

	

	
