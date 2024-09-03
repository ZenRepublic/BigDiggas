extends OptionButton
class_name MapColorPicker

@export var map_colors:MapColors

signal on_color_selected

func setup() -> void:
	#option indexes start from 0, separators also get their indexes :<<<
	var color_index:int=0
	add_separator("Terrain")
	color_index += 1
	
	for key in map_colors.terrain_colors.keys():
		var color:Color = map_colors.terrain_colors[key]
		add_icon_item(create_color_texture(color),key)
		set_item_metadata(color_index,color)
		color_index+=1
		
	add_separator("Assets")
	color_index += 1
	
	for key in map_colors.asset_colors.keys():
		var color:Color = map_colors.asset_colors[key]
		add_icon_item(create_color_texture(color),key)
		set_item_metadata(color_index,color)
		color_index+=1
		
	_on_item_selected(1)
		
func create_color_texture(color:Color) -> Texture2D:
	var image:Image = Image.create(32,32,false,Image.FORMAT_RGBA8)
	for x in image.get_width():
		for y in image.get_height():
			image.set_pixel(x,y,color)
	var image_texture:ImageTexture = ImageTexture.create_from_image(image)
	var tex:Texture2D = image_texture as Texture2D
	return tex


func _on_item_selected(index:int):
	var selected_color:Color = get_item_metadata(index)
	emit_signal("on_color_selected",selected_color)
