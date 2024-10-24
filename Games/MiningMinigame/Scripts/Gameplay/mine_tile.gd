extends Area2D
class_name MineTile

@export var default_layers:Array[Texture2D]
@export var visual:Sprite2D
@export var rock_particles_scn:PackedScene

@onready var collider:CollisionShape2D = $Collider
@onready var shadow:Sprite2D = $Shadow

var layers:Array[Texture2D]

var pos_in_grid:Vector2

var health:int
var destroyed:bool

var occupied_by:MineItem

var tile_floor:FloorGenerator

var focused:bool

signal on_selected(tile:MineTile)
signal on_destroyed(tile:MineTile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !focused:
		return
		
	var mouse_pos = get_global_mouse_position()
	var local_mouse_pos = shadow.get_global_transform().affine_inverse() * mouse_pos
	var normalized_mouse_pos = local_mouse_pos / shadow.texture.get_size() + Vector2(0.5,0.5)
	shadow.material.set_shader_parameter("center",normalized_mouse_pos)
	var player:PlayerManager = get_tree().get_first_node_in_group("Player")
	shadow.material.set_shader_parameter("feather",lerp(2.5,0.38,player.cam.get_normalized_zoom()))
	pass
	
func setup(grid_pos:Vector2,noise_strength:int,floor_generator:FloorGenerator) -> void:
	tile_floor = floor_generator
	
	var floor_data = floor_generator.floor_data
	if floor_data.layers.size() > 0:
		layers = floor_data.layers
		
	pos_in_grid = grid_pos
	self.global_position = Vector2(grid_pos.x*visual.texture.get_width(),grid_pos.y*visual.texture.get_height())
	#the noise received needs to be divided by the amount of layers and set accordingly
	
	health = 0
	for i in range(layers.size()):
		var layer_global_depth = tile_floor.get_global_layer_depth(i)
		if layer_global_depth>=noise_strength:
			health += floor_data.layer_healths[i]
		
	if health == 0:
		deactivate()
	else:
		visual.texture = tile_floor.floor_data.get_layer_by_health(health)

func _on_input_event(_viewport, event, _shape_idx):
	#prevent hidden layers to be clickable, only the top layer should be clickable
	if event.is_action_pressed("MouseClick"):
		if !tile_floor.can_be_hit(self):
			return
		
		var player:PlayerManager = get_tree().get_first_node_in_group("Player")
		player.handle_tile_interaction(self)
		on_selected.emit(self)
		
func can_hit() -> bool:
	return tile_floor.can_be_hit(self)
	
func is_lethal_hit(damage:int) -> bool:
	return health - damage <= 0
		
func get_hit(damage:int,apply_overload_damage:bool=true) -> void:
	if !tile_floor.can_be_hit(self):
			return
	
	if rock_particles_scn!=null:
		emit_rock_particles()
	
	if is_lethal_hit(damage):
		deactivate()
		if occupied_by!=null:
			occupied_by.try_uncover(self)
		on_destroyed.emit(self)
		
		#activate the next tile below and give it the remainder of damage if it can take it
		var damage_overload:int = abs(health-damage)
		var map_manager:MapManager = get_tree().get_first_node_in_group("MapManager")
		var tile_below:MineTile = map_manager.get_topmost_active_tile_at_position(pos_in_grid)
		if apply_overload_damage and tile_below!=null and damage_overload > 0:
			tile_below.get_hit(damage_overload)
		return
	
	health -= damage
	visual.texture = tile_floor.floor_data.get_layer_by_health(health)
	
func emit_rock_particles() -> void:	
	var particles:Node2D = rock_particles_scn.instantiate()
	particles.get_child(0).process_material.set("color",tile_floor.floor_data.debris_color)
	get_tree().root.get_node("MiningMinigame/ParticlesLayer").add_child(particles)
	#add_child(particles)
	particles.global_position = self.global_position
	particles.z_index = 1

func deactivate() -> void:
	destroyed=true
	visual.visible=false
	collider.disabled=true
	shadow.visible=false
	
func activate() -> void:
	collider.disabled=false
	
func focus_start() -> void:
	focused=true

func focus_end() -> void:
	focused=false
