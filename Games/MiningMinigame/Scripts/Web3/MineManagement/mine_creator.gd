extends Node

@export var token_selection:OptionButton
@export var collection_selection:OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await RubianServer.get_mine_manager_data()
	#if token_selection.item_count == 0:
	fill_tokens()
	#if collection_selection.item_count == 0:
	fill_collections()
	pass # Replace with function body.

func fill_tokens() -> void:
	var tokens:Array = await RubianServer.get_verified_tokens()
	print(tokens)
	var index=0
	for i in range(tokens.size()):
		var mint:Pubkey = Pubkey.new_from_string(tokens[i]["token_id"])
		#var token_data:Token = await SolanaService.asset_manager.get_asset_from_mint(mint)
		token_selection.add_item(tokens[i]["name"],index)
		token_selection.set_item_metadata(index,mint)
	
func fill_collections() -> void:
	var collections:Array = await RubianServer.get_verified_collections()
	
	var index=0
	for i in range(collections.size()):
		var mint:Pubkey = Pubkey.new_from_string(collections[i]["collection_id"])
		#var token_data:Token = await SolanaService.asset_manager.get_asset_from_mint(mint)
		collection_selection.add_item(collections[i]["name"],index)
		collection_selection.set_item_metadata(index,mint)
