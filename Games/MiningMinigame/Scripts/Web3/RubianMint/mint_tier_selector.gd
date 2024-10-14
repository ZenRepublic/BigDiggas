extends Node
class_name MintTierSelector

@export var mint_token:DisplayableAsset

@export var tier_containers:Array[Container]
@export var tier_prices:Array[int]

@export var curr_tier_color:Color


func select_mint_tier(mint_token:Token) -> int:
	print("SETTING TIER")
	for tier in tier_containers:
		tier.modulate = Color.WHITE
	
	var token_balance = await mint_token.get_balance()
	var mint_tier_id:int = -1
	
	for i in range(tier_prices.size()):
		if token_balance>=tier_prices[i]:
			mint_tier_id += 1
		else:
			break
		
	if mint_tier_id != -1:
		tier_containers[mint_tier_id].modulate = curr_tier_color
		
	return mint_tier_id
