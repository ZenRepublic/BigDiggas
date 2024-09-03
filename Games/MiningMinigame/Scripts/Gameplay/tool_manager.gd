extends Node2D
class_name ToolManager

@export var cam:PlayerCamera
@export var input:PlayerInput

@export var speed:float = 100
@export var stiffness:float = 1000.0
@export var damping:float = 0.1

@export var min_light_strength:float = 0.1
@export var max_light_strength:float = 0.3

@export var damage_colors:Dictionary

@onready var tool_light:PointLight2D = $Light

@export var mining_tools:Array[MiningTool]

signal on_tool_hit(tool:MiningTool)
# Initial velocity of the sprite
var velocity: Vector2 = Vector2.ZERO

var toolbelt:Toolbelt

var active_tool:MiningTool

var map_manager:MapManager
var player_manager:PlayerManager

var focused_tile:MineTile
# Called when the node enters the scene tree for the first time.
func setup():
	for tool in mining_tools:
		tool.visible=false
	
	switch_tool(0)
	player_manager = get_tree().get_first_node_in_group("Player")
	player_manager.on_freeze_state_changed.connect(handle_player_freeze)
	toolbelt = player_manager.hud.toolbelt
	toolbelt.on_tool_selected.connect(switch_tool)
	
	self.global_position = get_global_mouse_position()
	cam.on_camera_zoom.connect(adjust_light)
		
	map_manager = get_tree().get_first_node_in_group("MapManager")

	#get_parent().call_deferred("move_child",self,get_parent().get_child_count()-1)
	pass # Replace with function body


var jiggle_start_delay:float = 0.3
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	active_tool.visible = !input.mouse_active
	
	if !active_tool.visible:
		return
		
	if active_tool.is_hitting:
		return
		
	if !player_manager.frozen:
		handle_tile_focus()
		
	var mouse_position:Vector2 = get_global_mouse_position()
		
	if jiggle_start_delay>0:
		self.global_position = mouse_position
		jiggle_start_delay-=delta
		return
		
	# Calculate the difference between the sprite's position and the mouse position
	var difference: Vector2 = mouse_position - self.global_position
	# Calculate the acceleration based on Hooke's law (F = -kx) and damping (F = -bv)
	var acceleration: Vector2 = difference * stiffness - velocity * damping
	
	velocity += acceleration * delta
	self.global_position += velocity * delta
	

func switch_tool(tool_id:int) -> void:
	if active_tool!=null:
		active_tool.visible=false
	active_tool = mining_tools[tool_id]
	active_tool.visible=true
	
	if focused_tile!=null:
		update_hit_indications()
	
func adjust_light(zoom_strength:float) -> void:
	tool_light.texture_scale = 1-zoom_strength
	tool_light.texture_scale = clamp(tool_light.texture_scale,0.1,1)
	tool_light.energy = lerp(min_light_strength,max_light_strength,zoom_strength)
	
func get_hit_data(grid_pos:Vector2) -> Dictionary:
	return active_tool.get_hit_cells(grid_pos)
	
func is_hitting() -> bool:
	return active_tool.is_hitting
	
func handle_player_freeze(frozen:bool) -> void:
	if frozen:
		hide_all_indications()
	else:
		if focused_tile!=null:
			update_hit_indications()
		
	
func update_hit_indications() -> void:
	hide_all_indications()
	#don't show any indications even around the tile if the main one not hittable	
	if !focused_tile.can_hit():
		return
		
	var hover_cells:Dictionary = get_hit_data(focused_tile.pos_in_grid)
	
	#enable only relevant tiles with specified damage color	
	for key in hover_cells.keys():
		if !map_manager.is_in_bounds(key):
			continue
			
		if !map_manager.get_topmost_active_tile_at_position(key).can_hit():
			continue
			
		var hover_indication:HoverIndication = map_manager.hover_indications[key]
		var damage:int = hover_cells[key]
		var damage_color:Color =  damage_colors[damage]
		hover_indication.show(damage_color)
		
func hide_all_indications() -> void:
	for key in map_manager.hover_indications.keys():
		var indication:HoverIndication = map_manager.hover_indications[key]
		indication.hide()
	
func process_hit(successful_hit:bool, hit_pos:Vector2) -> void:
	on_tool_hit.emit(active_tool)
	await active_tool.play_hit_anim(successful_hit,hit_pos)
	
func handle_tile_focus() -> void:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collide_with_bodies=false
	params.collide_with_areas=true
	
	var result:Array = space.intersect_point(params)
	if result.size() > 0:
		var new_focused_tile:MineTile = result[0]["collider"] as MineTile
		#if whatever we collided with is not a tile		
		if new_focused_tile == null or new_focused_tile is not MineTile:
			if focused_tile != null:
				on_tile_focus_lost(focused_tile)
			
		if new_focused_tile != focused_tile:
			if focused_tile!= null:
				on_tile_focus_lost(focused_tile)
			if new_focused_tile != null:
				on_tile_focused(new_focused_tile)
			
	elif focused_tile != null:
		on_tile_focus_lost(focused_tile)

	
func on_tile_focused(new_focused_tile:MineTile) -> void:
	new_focused_tile.focus_start()
	focused_tile = new_focused_tile
	update_hit_indications()
	pass
	
func on_tile_focus_lost(tile:MineTile) -> void:
	tile.focus_end()
	hide_all_indications()
	focused_tile=null
	pass
