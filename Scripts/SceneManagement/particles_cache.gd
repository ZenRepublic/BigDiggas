extends CanvasLayer
class_name ParticleCache

@export var scene_caches:Dictionary
@export var frames_to_process:int = 5

func cache_particles(scene_to_load:String) -> void:
	if !scene_caches.has(scene_to_load):
		return
		
	var particle_scenes:Array = scene_caches[scene_to_load]
	for particle_scn in particle_scenes:
		var particle_instance = particle_scn.instantiate()
		add_child(particle_instance)
		
		for i in range(frames_to_process):
			await get_tree().process_frame
			
		print("loaded: ",particle_instance.name)
		particle_instance.queue_free()