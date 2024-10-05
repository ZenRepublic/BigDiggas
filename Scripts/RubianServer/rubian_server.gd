extends Node

@export var use_localhost:bool=false
@export var localhost_port:int = 5000

var SERVER_LINK:String = "https://rubians-server-625d2ae63a81.herokuapp.com/"

func _ready() -> void:
	if use_localhost:
		SERVER_LINK = "http://localhost:%s/" % str(localhost_port)

func register_user(user:Pubkey) -> void:
	if user == null:
		push_error("User not found")
		return
		
	var headers:Array = ["Content-type: application/json"]
	var body:Dictionary = {
		"walletAddress":user.to_string()
	}
	var response:Dictionary = await send_post_request(JSON.stringify(body),headers,SERVER_LINK+"users/register")
	
func get_mine_manager_data() -> Dictionary:
	var response:Dictionary = await send_get_request(SERVER_LINK+"minemanager")
	return response["collections"]
	
func get_oracle_signature(transaction:Transaction) -> PackedByteArray:
	var serialized_tx:PackedByteArray = transaction.serialize()
	print(serialized_tx)
	var headers:Array = ["Content-type: application/json"]
	var body:Dictionary = {
		"transaction":serialized_tx
	}
	var response:Dictionary = await send_post_request(JSON.stringify(body),headers,SERVER_LINK+"transactions/sign")
	print(response)
	return response["transaction"]

func send_get_request(request_link:String) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	# Perform a GET request. The URL below returns JSON as of writing.
	var request = http_request.request(request_link)
	if request != OK:
		push_error("An error occurred in the HTTP request.")
		return {}
		
	var raw_response = await http_request.request_completed
	http_request.queue_free()
	var response_dict = parse_http_response(raw_response,true)
	
	if response_dict["response_code"] != 200:
		print(response_dict)
		return {}
	
	if response_dict["body"] == null:
		return {}
		
	return response_dict["body"]
	
func send_post_request(body, headers:Array,endpoint:String) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var request = http_request.request(endpoint,headers,HTTPClient.METHOD_POST,body)
	if request != OK:
		push_error("An error occurred in the HTTP request.")
		return {}
		
	var raw_response = await http_request.request_completed
	http_request.queue_free()
	var response_dict = parse_http_response(raw_response,true)
	print(response_dict)

	if response_dict["response_code"] != 200:
		print(response_dict)
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
