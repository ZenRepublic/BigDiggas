extends Node
class_name ImagePrompter

@export var image_size:int = 256
@export var amount_to_generate:int = 1
@export var temperature:float = 0.5
@export var model:String
var end_point:String = "https://api.openai.com/v1/images/generations"

var http_request_image:HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func generate_image(prompt:String) -> Texture2D:
	var body = JSON.stringify({
		"prompt": prompt,
		"n": amount_to_generate,
		"quality": "standard",
		"size" : "%sx%s" % [image_size,image_size],
		"model": model
	})
	
	var response:Dictionary = await OpenAI.send_prompt_request(body, end_point)
	var image_url = response["data"][0]["url"]
	var img_tex:Texture2D = await parse_prompted_image(image_url,image_size)
	
	return img_tex
	
	
func parse_prompted_image(image_link:String,size:int=512) -> Texture2D:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var request = http_request.request(image_link)
	if request != OK:
		push_error("An error occurred in the HTTP request.")
		return null
	
	var raw_response = await http_request.request_completed
	http_request.queue_free()
	
	var response_dict = OpenAI.parse_http_response(raw_response)
	
	if response_dict["response_code"] != 200:
		push_error("Failed to fetch Token Image")
		return null
	
	var image = Image.new()
	var img_load_request = image.load_png_from_buffer(response_dict["body"])
	if img_load_request != OK:
		print("Failed to parse the prompted image")
		return null
		
	image.resize(size,size)
	return ImageTexture.create_from_image(image)
