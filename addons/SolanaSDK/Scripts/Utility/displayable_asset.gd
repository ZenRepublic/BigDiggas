extends Node
class_name DisplayableAsset

@export var visual:TextureRect
@export var image_size = 512

@export var name_label:Label
@export var balance_label:Label
@export var select_button:BaseButton

var asset:WalletAsset

signal on_selected(displayable:DisplayableAsset)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if select_button!=null:
		select_button.pressed.connect(handle_select)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_data(asset:WalletAsset) -> void:
	self.asset = asset
	if name_label!=null:
		name_label.text = asset.metadata.get_token_name()
		if name_label.text=="":
			name_label.text="name missing"
	
	if asset.image!=null:
		visual.texture = asset.image
	else:
		await asset.try_load_image(image_size)
		if asset.image!=null:
			visual.texture = asset.image
		else:
			print("Couldn't load the image for mint: %s" % asset.mint.to_string())
			
	if balance_label != null and asset is Token:
		var token = asset as Token
		balance_label.text = str(await token.get_balance())
		

func set_data_manual(texture:Texture2D, nft_name:String, balance:float=0.0) -> void:
	if visual!=null:
		visual.texture = texture
	if name_label!=null:
		name_label.text = nft_name
		
	if balance_label!=null and balance != 0.0:
		balance_label.text = str(balance)
	
func get_associated_asset() -> WalletAsset:
	return asset
	
func handle_select() -> void:
	on_selected.emit(self)
