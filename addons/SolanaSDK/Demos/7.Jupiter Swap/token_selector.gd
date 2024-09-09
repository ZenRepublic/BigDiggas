extends Node
class_name TokenSelector

@export var token_entry_scn:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !SolanaService.asset_manager.is_loading


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
