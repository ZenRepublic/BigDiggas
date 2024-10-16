extends Node
class_name HeliusAPI
#can add unsafeMax as well
enum PriorityFeeLevel {min,low,medium,high,veryHigh}

@export var helius_rpc:String
@export var priority_fee_level:PriorityFeeLevel

func get_estimated_priority_fee(transaction:Transaction, use_recommended_fee:bool=true) -> int:
	if helius_rpc == "":
		push_error("Helius RPC not provided!")
		return 0
		
	var options:Dictionary
	if use_recommended_fee:
		options = {"recommended": true}
	else:
		options = {"includeAllPriorityFeeLevels": true}
		
	var serialized_tx:String = SolanaUtils.bs58_encode(transaction.serialize())
	var headers:Array = ["Content-type: application/json"]
	var body:Dictionary = {
		"jsonrpc": "2.0",
		"id": "1",
		"method": "getPriorityFeeEstimate",
		"params": [{
			"transaction":serialized_tx,
			"options": options
		}]
	}
	var response:Dictionary = await send_post_request(JSON.stringify(body),headers,helius_rpc)
	if response.size() == 0 or response.has("error"):
		push_error("failed to receive signature by the server")
		return 0
	
	var fee_estimate:int
	if use_recommended_fee:
		fee_estimate = int(response["result"]["priorityFeeEstimate"])
	else:
		var level:String = str(PriorityFeeLevel.keys()[priority_fee_level])
		fee_estimate = int(response["result"]["priorityFeeLevels"][level])
		
	return fee_estimate
	
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
