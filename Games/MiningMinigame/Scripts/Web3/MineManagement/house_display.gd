extends Node
class_name HouseDisplay

@export var house_name_label:Label
@export var active_campaigns_label:Label
@export var total_campaigns_label:Label
@export var unique_players_label:NumberLabel

@export var house_fees_label:Label
@export var sol_fees_label:Label

@export var house_edit_input_system:HouseInputSystem

var curr_selected_house_data:Dictionary
var decimals:int
var house_pda:Pubkey
# Called when the node enters the scene tree for the first time.
func set_house_data(data:Dictionary) -> void:
	curr_selected_house_data = data

	house_name_label.text = data["houseName"]
	house_pda = ClubhousePDA.get_house_pda(data["houseName"])
	
	active_campaigns_label.text = str(data["openCampaigns"])
	total_campaigns_label.text = str(data["totalCampaigns"])
	unique_players_label.set_value(data["uniquePlayers"])
	
	var house_vault_balance:float = data["unclaimedHouseFees"]/pow(10,data["houseCurrencyDecimals"])
	house_fees_label.text = "%s SOL" % str(house_vault_balance)
	var house_sol_fee_balance:float = data["unclaimedSolFees"]/pow(10,9)
	sol_fees_label.text = "%s SOL" % str(house_sol_fee_balance)
	
	await set_input_system_fields(data)
	
func set_input_system_fields(house_data:Dictionary) -> void:
	var data_to_set:Dictionary
	
	var house_config:Dictionary = house_data["config"]
	
	decimals = await SolanaService.get_token_decimals(house_data["houseCurrency"].to_string())
	data_to_set["oracleKey"] = house_config["oracleKey"].to_string()
	data_to_set["campaignCreationFee"] = str(house_config["campaignCreationFee"]/pow(10,decimals))
	data_to_set["campaignManagerDiscount"] = str((house_config["campaignCreationFee"]-house_config["campaignManagerDiscount"])/pow(10,decimals))
	data_to_set["claimFee"] = str(house_config["claimFee"]/pow(10,9))
	data_to_set["rewardsTax"] = str(house_config["rewardsTax"]/10.0)
	
	house_edit_input_system.set_input_fields_data(data_to_set)
	
