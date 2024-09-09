extends Node
class_name MineManager

@onready var screen_manager:ScreenManager = $ScreenManager

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	
func on_visibility_changed() -> void:
	if self.visible:
		screen_manager.switch_active_panel(1)
