extends Node
class_name NFTSelector

@export var selectable_nft:DisplayableNFT
@export var display_system:NftDisplaySystem

@export var default_visual:Texture2D
@export var default_name:String

var selected_nft:Nft

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_system.visible=false
	display_system.on_nft_selected.connect(select_nft)
	selectable_nft.on_selected.connect(show_display_system)
	pass # Replace with function body.

func show_display_system(_selected_nft:DisplayableNFT) -> void:
	display_system.visible=true

func select_nft(display_selection:Nft) -> void:
	if display_selection == null:
		selected_nft = null
		selectable_nft.visual.texture = default_visual
		selectable_nft.name_label.text = default_name
		return
		
	selected_nft = display_selection
	await selectable_nft.set_data(selected_nft)
