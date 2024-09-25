extends DataInputSystem
class_name HouseInputSystem

func handle_fields_updated() -> void:
#	manager fee can't be bigger than standard fee
	var input_data:Dictionary = get_input_data()
	if input_data["campaignManagerDiscount"] > input_data["campaignCreationFee"]:
		get_input_field("campaignManagerDiscount").clear()

	input_submit_button.disabled = !get_inputs_valid()
