extends Control
@export var canvas:TextureRect
@export var map_dimensions:Vector2 = Vector2(64,64)
@export var pixel_resolution: int = 10  # Each original pixel is a 10x10 block
@export var overlay_grid:OverlayGrid

@export var export_path:String
@onready var color_picker:MapColorPicker = $MapColorPicker
@onready var brush_size_slider:HSlider = $BrushSizeSlider
@onready var map_name_field:InputField = $"MapNameInputField\\"

var map_size:Vector2
var image: Image
var texture: ImageTexture

var active_color:Color

func _ready():
	map_size = map_dimensions*pixel_resolution
	
	# Create and initialize the image
	image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 1))  # Fill the image with white color
	set_canvas_texture(image)
	overlay_grid.draw_grid(canvas,pixel_resolution)
	
	color_picker.on_color_selected.connect(set_active_color)
	color_picker.setup()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			draw_point(event.position)
	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			draw_point(event.position)

func draw_point(position: Vector2):
	# Convert global position to local position on the canvas
	var local_position = canvas.get_local_mouse_position()
	var canvas_pos:Vector2 = Vector2(int(local_position.x),int(local_position.y))

	if is_in_bounds(canvas_pos):
		#var pixel_chunk = get_pixel_chunk(canvas_pos)
		var pixel_chunk = get_pixels_with_brush(canvas_pos,brush_size_slider.value)
		for pixel in pixel_chunk:
			image.set_pixel(pixel.x, pixel.y, active_color)  # Example: Draw with black color
		set_canvas_texture(image)
		
func set_canvas_texture(image:Image) -> void:
	texture = ImageTexture.create_from_image(image)
	canvas.texture = texture
	canvas.size = Vector2(image.get_width(),image.get_height())
	
func set_active_color(color:Color) -> void:
	active_color = color
		
func is_in_bounds(pos:Vector2,for_blocks:bool=false) -> bool:
	var size:Vector2 = map_size
	if for_blocks:
		size /= pixel_resolution
	return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y
	
# Function to get pixels affected by the brush size
func get_pixels_with_brush(draw_pos: Vector2, brush_size: int) -> Array:
	var affected_pixels = []
	var block_index:Vector2 = get_block_index(draw_pos)

	var visited_blocks:Array
	#if the brush size is 1, we dont need to go through any neighbours
	var neighbour_depth = brush_size-1
	# Calculate the range of blocks affected by the brush size
	for bx in range(block_index.x - neighbour_depth, block_index.x + neighbour_depth + 1):
		for by in range(block_index.y - neighbour_depth, block_index.y + neighbour_depth + 1):
			if !is_in_bounds(Vector2(bx,by),true):
				continue
			var curr_block_index = Vector2(bx, by)
			if visited_blocks.has(curr_block_index):
				continue
			visited_blocks.append(curr_block_index)
			var pixels_in_block = get_pixel_chunk(curr_block_index)
			affected_pixels += pixels_in_block

	return affected_pixels
	
func get_block_index(draw_pos:Vector2) -> Vector2:
	#get which block the draw position belongs to
	var block_x = int(draw_pos.x / pixel_resolution)
	var block_y = int(draw_pos.y / pixel_resolution)
	return Vector2(block_x,block_y)
	
#because one pixel will be drawing multiple pixels
func get_pixel_chunk(block_index:Vector2) -> Array:
	var chunk = []
	var start_x = block_index.x * pixel_resolution
	var start_y = block_index.y * pixel_resolution

	for x in range(start_x, start_x + pixel_resolution):
		for y in range(start_y, start_y + pixel_resolution):
			chunk.append(Vector2(x, y))
			
	return chunk


func export_map() -> void:
	if map_name_field.text.length()==0:
		return
	var path = "%s/%s.png" % [export_path,map_name_field.text]
	
	#resize the map so that blocks turn to single pixels
	var final_map:Image = Image.create_from_data(
		image.get_width(),
		image.get_height(),
		false,
		Image.FORMAT_RGBA8,
		image.get_data()
		)
	final_map.resize(map_dimensions.x,map_dimensions.y,Image.INTERPOLATE_BILINEAR)
	var error:Error = final_map.save_png(path)
	if error == 0:
		print("Map Exported Successfully!")
