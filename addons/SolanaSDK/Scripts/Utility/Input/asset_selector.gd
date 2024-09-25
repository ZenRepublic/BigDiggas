extends Node
class_name AssetSelector

@export var displayable_asset:DisplayableAsset
@export var display_system:AssetDisplaySystem

@export var default_visual:Texture2D
@export var default_name:String
@export var is_optional:bool=false

var selected_asset:WalletAsset
signal on_selected(selected_asset:WalletAsset)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_system.visible=false
	display_system.on_asset_selected.connect(select_asset)
	displayable_asset.on_selected.connect(show_display_system)
	
	if default_visual == null:
		displayable_asset.visual.visible=false
	if default_name != "":
		displayable_asset.name_label.text = default_name
	pass # Replace with function body.

func show_display_system(_selected_asset:DisplayableAsset) -> void:
	display_system.visible=true

func select_asset(display_selection:WalletAsset) -> void:
	if display_selection == null:
		selected_asset = null
		displayable_asset.visual.texture = default_visual
		if default_visual == null:
			displayable_asset.visual.visible=false
			
		displayable_asset.name_label.text = default_name
		on_selected.emit(null)
		return
	
	displayable_asset.visual.visible=true
	selected_asset = display_selection
	on_selected.emit(selected_asset)
	await displayable_asset.set_data(selected_asset)
	
func is_valid() -> bool:
	if selected_asset == null:
		return is_optional
	
	return selected_asset != null
		
