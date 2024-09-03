extends Control
class_name OverlayGrid

@export var grid_color:Color
var canvas:TextureRect
var grid_spacing:int
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func draw_grid(canvas:TextureRect,pixel_resolution:int) -> void:
	self.canvas = canvas
	size = canvas.size
	
	grid_spacing = pixel_resolution
	queue_redraw()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	for x in range(canvas.position.x, canvas.position.x+canvas.size.x, grid_spacing):
		draw_line(Vector2(x, canvas.position.y), Vector2(x, canvas.position.y+canvas.size.y), grid_color)
	for y in range(canvas.position.y, canvas.position.y+canvas.size.y, grid_spacing):
		draw_line(Vector2(canvas.position.x, y), Vector2(canvas.position.x+canvas.size.x, y), grid_color)
