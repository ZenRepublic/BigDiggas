extends Node

@export var API_KEY:String
@export var path_to_key:String
@export var temperature:float = 0.5
@export var max_tokens:int = 1024
@export var model:String

@onready var image_prompter:ImagePrompter = $ImagePrompter


var end_point:String = "https://api.openai.com/v1/chat/completions"
var headers:Array

var alive_sessions:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if API_KEY == "":
		API_KEY = fetch_key(path_to_key)
		if API_KEY == "":
			return
			
	headers = ["Content-type: application/json", "Authorization: Bearer "+ API_KEY]
	
	prompt_session("hello chat how are you? answer in 3 words please","intro")
	pass # Replace with function body.
	
#simple prompt to try and get some information without any follow-up
func prompt_single(message:String) -> String:
	var message_stream = [{
		"role":"user",
		"content":message
	}]
	
	var body = JSON.stringify({
		"messages": message_stream,
		"temperature": temperature,
		"max_tokens" : max_tokens,
		"model" : model
	})
	
	var response:Dictionary = await send_prompt_request(body, end_point)
	if response.is_empty():
		#print("Failed to receive response from prompt")
		return ""
	return response["choices"][0]["message"]["content"]
	
func setup_session(session_id:String, ruleset:String) ->  void:
	if alive_sessions.has(session_id):
		print("Session with this ID already exists!")
		return
	
	alive_sessions[session_id] = []
	alive_sessions[session_id].append({
		"role":"user",
		"content":ruleset+"\n"
	})
	
	
func prompt_session(message:String,session_id:String) -> String:
	if !alive_sessions.has(session_id):
		print("This session hasn't been created yet!")
		return ""
	
	#if there's only one message in the current session, it is the ruleset, so just append the message to it
	#so that it would make one message in total to start		
	if alive_sessions[session_id].size() == 1:
		alive_sessions[session_id][0]["content"] += message
	else:	
		alive_sessions[session_id].append({
			"role":"user",
			"content":message
		})
		
	var body = JSON.stringify({
		"messages": alive_sessions[session_id],
		"temperature": temperature,
		"max_tokens" : max_tokens,
		"model" : model
	})
	
	var response:Dictionary = await send_prompt_request(body, end_point)
	if response.is_empty():
		print("Failed to receive response from prompt")
		return ""
		
	var message_content:String = response["choices"][0]["message"]["content"]
	print(response["usage"])
	alive_sessions[session_id].append({
		"role":"system",
		"content":message_content
	})
	return message_content
	
func send_prompt_request(prompt_body, endpoint:String) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var request = http_request.request(endpoint,headers,HTTPClient.METHOD_POST,prompt_body)
	if request != OK:
		push_error("An error occurred in the HTTP request.")
		return {}
		
	var raw_response = await http_request.request_completed
	http_request.queue_free()
	var response_dict = parse_http_response(raw_response,true)

	if response_dict["response_code"] != 200:
		push_error("Failed to parse the Prompt")
		return {}
	
	return response_dict["body"]
	
func parse_http_response(response:Array, body_to_json:bool=false) -> Dictionary:
	var body = response[3]
	if body_to_json:
		var json = JSON.new()
		json.parse(response[3].get_string_from_utf8())
		body = json.get_data()
	
	var dict = {
		"result":response[0],
		"response_code":response[1],
		"headers":response[2],
		"body":body
	}
	return dict
	

func fetch_key(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		#push_error("Failed to fetch OpenAI API key")
		return ""
	var content = file.get_as_text()
	return content
