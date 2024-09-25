extends Node
class_name DisplayableAsset

@export var select_button:BaseButton
@export var visual:TextureRect
@export var image_size = 512
@export_file("*.png","*.jpg") var missing_icon_path:String

@export var name_label:Label
@export_category("Displayable Token Settings")
@export var balance_label:NumberLabel
@export var auto_load_balance:bool

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
			if missing_icon_path!=null:
				visual.texture = load(missing_icon_path)
			print("Couldn't load the image for mint: %s" % asset.mint.to_string())
			
	if asset is Token:
		var token = asset as Token
		if balance_label!=null:
			balance_label.set_value(await token.get_balance())
		if auto_load_balance:
			SolanaService.transaction_manager.on_tx_finish.connect(update_balance)
		

func set_data_manual(texture:Texture2D, nft_name:String, balance:float=0.0) -> void:
	if visual!=null:
		visual.texture = texture
	if name_label!=null:
		name_label.text = nft_name
		
	if balance_label!=null and balance != 0.0:
		balance_label.set_value(balance)
	
func get_associated_asset() -> WalletAsset:
	return asset
	
func handle_select() -> void:
	on_selected.emit(self)
	
func update_balance(tx_data:TransactionData) -> void:
	if !tx_data.is_successful():
		return
	
	if balance_label == null:
		return
		
	var token:Token = asset as Token
	balance_label.set_value(await token.get_balance(true))
	
