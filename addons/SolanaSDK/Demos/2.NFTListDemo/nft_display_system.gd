extends Node
class_name NftDisplaySystem

@export var container:Container
@export var no_asset_overlay:Control
@export var minimum_entry_size:Vector2
@export var display_type:AssetManager.AssetType
@export var display_entry_scn:PackedScene

@export var load_all:bool
@export var close_on_select:bool
@export var destroy_on_close:bool

@export_category("Token Display Settings")

@export_category("NFT Display Settings")
@export var collection_filter:Array[NFTCollection]

var entries:Array

signal on_display_updated
signal on_asset_selected(asset:WalletAsset)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_display_updated.connect(handle_display_update)
	if load_all:
		load_all_nfts()
		
func load_all_nfts() -> void:
	SolanaService.asset_manager.on_asset_loaded.connect(add_to_list)
	SolanaService.asset_manager.on_asset_load_finished.connect(asset_load_finished)
	
#	load all nfts that have already been loaded and then add new ones as they load
	set_loaded_assets()
	
	if !SolanaService.asset_manager.assets_loaded:
		SolanaService.asset_manager.load_assets()
	

func set_loaded_assets() -> void:
	match display_type:
		AssetManager.AssetType.NFT:
			if collection_filter.size()==0:
				setup(SolanaService.asset_manager.get_owned_nfts())
			else:
				for collection in collection_filter:
					setup(SolanaService.asset_manager.get_nfts_from_collection(collection))
		AssetManager.AssetType.TOKEN:
			setup(SolanaService.asset_manager.get_owned_tokens())
			

func setup(assets:Array[WalletAsset],clear_previous:bool=false) -> void:
	print(assets)
	if clear_previous && entries.size()!=null:
		clear_display()
	
	if assets.size()==0:
		return
		
	for asset in assets:
		add_to_list(asset)
		
func add_to_list(asset:WalletAsset) -> void:
	if asset.asset_type != display_type:
		return
		
	if display_type == AssetManager.AssetType.NFT and !belongs_to_collection_filter(asset):
		return
		
	var entry_instance = display_entry_scn.instantiate()
	entry_instance.custom_minimum_size = minimum_entry_size
	container.add_child(entry_instance)
	
	match display_type:
		AssetManager.AssetType.NFT:
			var displayable_nft:DisplayableNFT = entry_instance as DisplayableNFT
			displayable_nft.set_data(asset)
			displayable_nft.on_selected.connect(handle_displayable_selection)
	
	entries.append(entry_instance)
	on_display_updated.emit()
	
func asset_load_finished(owned_assets:Array[WalletAsset])->void:
	on_display_updated.emit()
	pass
	
func handle_displayable_selection(selected_nft:DisplayableNFT) -> void:
	on_asset_selected.emit(selected_nft.nft)
	if close_on_select:
		close()
		
func select_none() -> void:
	on_asset_selected.emit(null)
	if close_on_select:
		close()
		
func clear_display() -> void:
	for entry in entries:
		entry.queue_free()
	
	entries.clear()
	on_display_updated.emit()
	
func handle_display_update() -> void:
	if no_asset_overlay!=null:
		no_asset_overlay.visible = (entries.size()==0)
		container.visible = !no_asset_overlay.visible
	
func close() -> void:
	self.visible = false
	if destroy_on_close:
		queue_free()
		
func belongs_to_collection_filter(nft:Nft) -> bool:
	if collection_filter.size() == 0:
		return true
		
	var pass_collection_filter= (collection_filter.size()==0)
	for collection in collection_filter:
		if collection.belongs_to_collection(nft):
			return true
			
	return false
