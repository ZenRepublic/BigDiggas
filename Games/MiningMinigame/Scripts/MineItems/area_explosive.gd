extends MineItem
class_name AreaExplosive

@export var max_damage:int=9
@export var explode_radius:int=3

@onready var animation_player:AnimationPlayer = $AnimationPlayer

@export var explode_particles_scn:PackedScene
@export var explode_wait_time:float = 0.5
@export var shake_strength:float =  20.0
	
func uncover() -> void:
	super.uncover()
	await explode()
	conclude_uncover()
	
func explode() -> void:
	audio_player.play_sound(0)
	await explode_animation()
	visual.visible=false
	
	var map_manager:MapManager = get_tree().get_first_node_in_group("MapManager")
	var middle_point:Vector2 = get_middle_point()

	# Loop through each tile in the grid
	for x in range(map_manager.map_width):
		for y in range(map_manager.map_height):
			var distance:float = sqrt(pow(x - middle_point.x, 2) + pow(y - middle_point.y, 2))
			if distance <= explode_radius:
				var tile_in_radius:MineTile = map_manager.get_topmost_active_tile_at_position(Vector2(x,y))
				var damage:int = lerp(max_damage,ceili(max_damage/float(explode_radius)),distance/explode_radius)
				tile_in_radius.get_hit(damage)
					
func explode_animation() -> void:
	z_index = 1
	animation_player.play("Explode")
	await get_tree().create_timer(explode_wait_time).timeout
	
	var player:PlayerManager = get_tree().get_first_node_in_group("Player")
	player.cam.start_shake(0.5,shake_strength)
	
	var game_manager:GameManager = get_tree().get_first_node_in_group("GameManager")
	game_manager.shockwave_manager.send_shockwave(self.global_position,player.cam,2)
	
	if explode_particles_scn!=null:
		var particles = explode_particles_scn.instantiate()
		get_tree().root.get_node("MiningMinigame/ParticlesLayer").add_child(particles)
		#add_child(particles)
		particles.global_position = self.global_position
		particles.z_index = 1
		await get_tree().create_timer(explode_wait_time).timeout
	

func get_middle_point() -> Vector2:
	var sum_position = Vector2()
	for tile in occupied_tiles:
		sum_position += tile.pos_in_grid
	return sum_position / occupied_tiles.size()
