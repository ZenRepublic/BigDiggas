extends Node

@onready var user_address_label:Label = $UserAddress
@onready var version_label:Label = $VersionLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	version_label.text = str(ProjectSettings.get_setting("application/config/version"))
	
	if SolanaService.wallet.get_pubkey()!=null:
		user_address_label.text = SolanaService.wallet.get_shorthand_address()
	pass # Replace with function body.
