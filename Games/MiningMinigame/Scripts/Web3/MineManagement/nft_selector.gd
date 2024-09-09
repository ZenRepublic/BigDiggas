extends Node
class_name NFTSelector

@export var displayable_nft:DisplayableNFT
@export var display_system:NftDisplaySystem

@export var default_visual:Texture2D
@export var default_name:String

var selected_nft:Nft
signal on_selected(selected_nft:Nft)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_system.visible=false
	display_system.on_asset_selected.connect(select_nft)
	displayable_nft.on_selected.connect(show_display_system)
	pass # Replace with function body.

func show_display_system(_selected_nft:DisplayableNFT) -> void:
	display_system.visible=true

func select_nft(display_selection:Nft) -> void:
	if display_selection == null:
		selected_nft = null
		displayable_nft.visual.texture = default_visual
		displayable_nft.name_label.text = default_name
		on_selected.emit(null)
		return
		
	selected_nft = display_selection
	on_selected.emit(selected_nft)
	await displayable_nft.set_data(selected_nft)
