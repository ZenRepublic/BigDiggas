extends Node
class_name MineManager

@onready var screen_manager:ScreenManager = $ScreenManager

@export var mines_list:Container
@export var mine_creator:MineCreateHandler

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)
	mine_creator.on_create_pressed.connect(try_create_mine)
	
func on_visibility_changed() -> void:
	if self.visible:
		screen_manager.switch_active_panel(1)
		
func try_create_mine(mine_data:Dictionary) -> void:
	print(mine_data)
	pass
