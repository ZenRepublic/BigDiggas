extends Node

@export var mint_token:DisplayableAsset

@export var tier_containers:Array[Container]
@export var tier_prices:Array[int]

@export var curr_tier_color:Color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mint_token.on_data_loaded.connect(set_mint_tier)
	pass # Replace with function body.


func set_mint_tier() -> void:
	for tier in tier_containers:
		tier.modulate = Color.WHITE
	
	var token_balance = mint_token.asset.get_balance()
	var mint_tier_id:int = -1
	
	for i in range(tier_prices.size()):
		if token_balance>=tier_prices[i]:
			mint_tier_id += 1
		else:
			break
		
	if mint_tier_id != -1:
		tier_containers[mint_tier_id].modulate = curr_tier_color
