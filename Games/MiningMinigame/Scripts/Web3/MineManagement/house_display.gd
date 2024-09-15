extends Node
class_name HouseDisplay

@export var house_name_label:Label
@export var active_campaigns_label:Label
@export var total_campaigns_label:Label
@export var unique_players_label:NumberLabel

@export var house_edit_data_handler:HouseEditDataHandler

var curr_selected_house_data:Dictionary
# Called when the node enters the scene tree for the first time.
func set_house_data(data:Dictionary) -> void:
	curr_selected_house_data = data
	
	var house_name_bytes:PackedByteArray = data["houseName"] as PackedByteArray
	house_name_label.text = house_name_bytes.get_string_from_utf8()
	
	active_campaigns_label.text = str(data["activeCampaigns"])
	total_campaigns_label.text = str(data["totalCampaigns"])
	unique_players_label.set_value(data["uniquePlayers"])
	
	house_edit_data_handler.set_fields(data)
