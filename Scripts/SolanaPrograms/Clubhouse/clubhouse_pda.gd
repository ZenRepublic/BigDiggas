extends Node
class_name ClubhousePDA

static var PROGRAM_ID:Pubkey = Pubkey.new_from_string("C1ubCwnK75ExARi8BoVzAvREDG29wJKyiwnf1hC8rgBU")
	
static func get_house_pda(house_name:String) -> Pubkey:
	var name_bytes = "house".to_utf8_buffer()
	var house_name_bytes = house_name.to_utf8_buffer()
	return Pubkey.new_pda_bytes([name_bytes,house_name_bytes],PROGRAM_ID)

static func get_house_currency_vault(house_pda:Pubkey) -> Pubkey:
	return Pubkey.new_pda_bytes([house_pda.to_bytes()],PROGRAM_ID)
