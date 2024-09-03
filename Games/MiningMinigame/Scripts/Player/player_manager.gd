extends Node2D
class_name PlayerManager

@onready var cam:Camera2D = $Cam
@onready var stats:PlayerStats = $Stats
@onready var hud:PlayerHud = $HUD
@onready var inventory:PlayerInventory = $Inventory

@export var input_handler:PlayerInput
@export var tool_manager:ToolManager
@export var movement_padding:float = 30.0

var map_manager:MapManager
var game_manager:GameManager
var frozen:bool

signal on_freeze_state_changed(frozen:bool)

func _init():
	add_to_group("Player")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#input_handler.connect("on_mouse_position_updated",move)
	map_manager = get_tree().get_first_node_in_group("MapManager")
	game_manager = get_tree().get_first_node_in_group("GameManager")

	self.global_position = map_manager.get_center_position()
	tool_manager.setup()
	inventory.clear_items()
	pass # Replace with function body.

	
func move(move_delta:Vector2)-> void:
	self.global_position += move_delta
	
	var map_bounds:Rect2 = map_manager.get_map_boundaries()
	#NEED TO ADJUST FOR CAMERA ZOOM
	#var viewport_size = cam.get_viewport_rect().size
	#var half_width = (viewport_size.x * cam.zoom.x) / 2
	#var half_height = (viewport_size.y * cam.zoom.y) / 2
	#print(half_width," ",half_height)
	
	var min_x = map_bounds.position.x - movement_padding
	var min_y = map_bounds.position.y - movement_padding
	var max_x = map_bounds.position.x + map_bounds.size.x + movement_padding
	var max_y = map_bounds.position.y + map_bounds.size.y + movement_padding
	
	self.global_position.x = clamp(self.global_position.x, min_x, max_x)
	self.global_position.y = clamp(self.global_position.y, min_y, max_y)
	
	
func handle_tile_interaction(clicked_tile:MineTile) -> void:
	if frozen or tool_manager.is_hitting():
		return
		
	var hit_data = tool_manager.get_hit_data(clicked_tile.pos_in_grid)
	var hit_success:bool =  hit_data.keys().size() > 0
	
#	the hit may also not be a success if hit an obstacle behind the tile
	var direct_tile_damage:int = hit_data[clicked_tile.pos_in_grid]
	if clicked_tile.occupied_by != null and clicked_tile.occupied_by.type == MineItem.ItemType.OBSTACLE:
		if clicked_tile.is_lethal_hit(direct_tile_damage):
			clicked_tile.get_hit(direct_tile_damage,false)
			hit_success=false
	
	freeze(true)
	await tool_manager.process_hit(hit_success,clicked_tile.global_position)
	
	# 0 hit keys means hit not successful
	if !hit_success:
		freeze(false)
		stats.use_energy(tool_manager.active_tool.energy_cost)
		return
		
	cam.start_shake(0.3,tool_manager.active_tool.shake_strength)
		
	for cell in hit_data.keys():
		var tile:MineTile = map_manager.get_topmost_active_tile_at_position(cell)
		if tile == null:
			continue
		tile.get_hit(hit_data[cell])
	
	await get_tree().create_timer(0.3).timeout

	#dont need to unfreeze if items discovered, cause that will happen once items are uncovered	
	if game_manager.items_uncovered.size()==0:
		freeze(false)

	stats.use_energy(tool_manager.active_tool.energy_cost)
		
	
func freeze(state:bool) -> void:
	frozen = state
	input_handler.input_enabled = !state
	on_freeze_state_changed.emit(state)
