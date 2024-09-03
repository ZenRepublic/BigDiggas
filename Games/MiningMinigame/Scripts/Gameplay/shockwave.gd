extends Node
class_name Shockwave

@export var default_force:float = 0.4
@export var default_size:float = 0.3
@export var default_thickness:float = 0.08

@onready var shockwave_rect:ColorRect = $ColorRect

var original_viewport_size:Vector2
var wave_strength:float

func _ready():
	var original_width:int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var original_height:int = ProjectSettings.get_setting("display/window/size/viewport_height")
	original_viewport_size = Vector2(original_width,original_height)

func normalize_position(world_pos: Vector2, camera: Camera2D) -> Vector2:
	var viewport_size:Vector2 = Vector2(get_viewport().size) 
	var scale:Vector2 = viewport_size/original_viewport_size
	
	var camera_size = viewport_size / camera.zoom / scale
	var camera_center_pos = camera.global_position

	var camera_top_left_pos = camera_center_pos - camera_size / 2
	var local_pos = world_pos - camera_top_left_pos
	
	var normalized_x = local_pos.x / camera_size.x
	var normalized_y = local_pos.y / camera_size.y
	
	return Vector2(normalized_x, normalized_y)

func send_shockwave(world_pos:Vector2,player_cam:Camera2D,strength:float = 1.0) -> void:
	wave_strength = strength * player_cam.zoom.x
	var mat:ShaderMaterial = shockwave_rect.material
	
	var wave_pos:Vector2 = normalize_position(world_pos,player_cam)
	#need to adjust for scaledUVs 
	var viewport_size:Vector2 = Vector2(get_viewport().size) 
	var aspect_ratio = viewport_size.x / viewport_size.y
	wave_pos.x = (wave_pos.x - 0.5) * aspect_ratio + 0.5
	
	mat.set_shader_parameter("center",wave_pos)
	
	var tween = get_tree().create_tween();
	tween.tween_method(process_shock_animation, 0.0, 1.0, 0.5)
	
func process_shock_animation(value:float) -> void:
	var mat:ShaderMaterial = shockwave_rect.material
	mat.set_shader_parameter("force",lerp(default_force*wave_strength,0.0,value))
	mat.set_shader_parameter("size",lerp(0.0,default_size*wave_strength,value))
	mat.set_shader_parameter("thickness",lerp(default_thickness*wave_strength,default_thickness*wave_strength/2,value))
