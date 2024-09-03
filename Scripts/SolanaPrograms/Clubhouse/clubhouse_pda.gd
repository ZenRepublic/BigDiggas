extends Node
class_name ClubhousePDA

static func get_admin_proof_pda(wallet_address:Pubkey,pid:Pubkey) -> Pubkey:
	var name_bytes = "program_admin".to_utf8_buffer()
	var address_bytes = wallet_address.to_bytes()
	return Pubkey.new_pda_bytes([name_bytes,address_bytes],pid)
	
static func get_house_pda(house_name:String,pid:Pubkey) -> Pubkey:
	var name_bytes = "house".to_utf8_buffer()
	var house_name_bytes = house_name.to_utf8_buffer()
	return Pubkey.new_pda_bytes([name_bytes,house_name_bytes],pid)
