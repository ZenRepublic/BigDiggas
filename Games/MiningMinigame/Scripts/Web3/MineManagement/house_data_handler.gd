extends Node
class_name HouseDataHandler

@export var input_field_system:InputFieldSystem
@export var data_submit_button:BaseButton

signal on_data_submitted(house_data:Dictionary)

func _ready() -> void:
	input_field_system.on_fields_updated.connect(update_button_state)
	data_submit_button.disabled=false
	data_submit_button.pressed.connect(submit_house_data)

func set_fields(house_data:Dictionary) -> void:
	pass
	
func update_button_state() -> void:
	var all_fields_valid:bool = true
	
	#	public key fields need to be verified as having 32bytes in base58 encoding
	#only after doing this adjusment (extra check for validity because input system doesnt have support for crypto)
	#we can check for whether all input is valid
	var pubkey_indexes:Array[int] = [1,2,3]
	for i in pubkey_indexes:
		if input_field_system.input_fields[i].is_optional and input_field_system.input_fields[i].text == "":
			continue
		if SolanaUtils.bs58_decode(input_field_system.input_fields[i].text).size() != 32:
			input_field_system.input_fields[i].clear()
			
			
	if !input_field_system.get_inputs_valid():
		all_fields_valid = false
		
#	manager fee can't be bigger than standard fee
	var input_data:Array = input_field_system.get_fields_data()
	if input_data[5] > input_data[4]:
		input_field_system.input_fields[5].clear()
		all_fields_valid=false
		
##	public key fields need to be verified as having 32bytes in base58 encoding
	#var pubkey_indexes:Array[int] = [1,2,3]
	#for i in pubkey_indexes:
		#if input_field_system.input_fields[i].is_optional and input_data[i] == "":
			#continue
		#if SolanaUtils.bs58_decode(input_data[i]).size() != 32:
			#input_field_system.input_fields[i].clear()
			#if !input_field_system.input_fields[i].is_optional:
				#all_fields_valid=false
		
		
	data_submit_button.disabled = !all_fields_valid
	
	
func submit_house_data() -> void:
	var input_data:Array = input_field_system.get_fields_data()
	var house_data:Dictionary = {
		"house_name":input_data[0],
		"oracle_key":pubkey_or_null(input_data[1]),
		"manager_collection":Pubkey.new_from_string(input_data[2]),
		"house_currency":pubkey_or_null(input_data[3]),
		"standard_creation_fee":input_data[4],
		"manager_discount_value":input_data[4] - input_data[5],
		"house_claim_fee":input_data[6],
		"manager_claim_fee":input_data[7]
	}
	
	on_data_submitted.emit(input_data)
	
func pubkey_or_null(address:String) -> Pubkey:
	if address.length() == 0:
		return null
		
	return Pubkey.new_from_string(address)
	

	

	
