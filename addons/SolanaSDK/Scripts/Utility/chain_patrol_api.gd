extends Node
class_name ChainPatrolAPI

var api_link:String = "https://app.chainpatrol.io/api/v2/"

func is_url_safe(url:String) -> bool:
	var headers:Array = ["Content-type: application/json"]
	var body:Dictionary = {
		"content":url
	}
	var response:Dictionary = await send_post_request(JSON.stringify(body),headers,api_link+"asset/details")
	if response.size() == 0 or response.has("error"):
		push_error("failed to get response for whether %s is safe or not!" % url)
		return false
	
	print(response)
	print(response["status"])
	return true
	

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
