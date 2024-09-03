extends Node
class_name CH

class ProgramAdminProof:
	static var ACCOUNT_DISCRIMINATOR = 6828378895819667010
	var wallet_address:Pubkey
	#
	static func deserialize(data_base64:String) -> ProgramAdminProof:
		var account_data:PackedByteArray = Marshalls.base64_to_raw(data_base64)
		
		var offset:int = 0
		var account_hash_value:int =  account_data.decode_u64(offset)
		offset += 8
		if account_hash_value != ACCOUNT_DISCRIMINATOR:
			return null
		var address:String = SolanaUtils.bs58_encode(account_data.slice(offset,offset+32))
		var admin_proof:ProgramAdminProof = ProgramAdminProof.new()
		admin_proof.wallet_address = Pubkey.new_from_bytes(account_data.slice(offset,offset+32))
		return admin_proof
		
class House:
	static var ACCOUNT_DISCRIMINATOR:int = -7506717733302660843
	var house_id:PackedByteArray
	var club_admin_collection:CollectionIdentifier
	var house_admin:Pubkey
	var house_currency:Pubkey
	var clubs_created:int
	var member_count:int
	var house_config:HouseConfig
	var house_currency_decimals:int
	var members_per_match:int
	
	var reserved3:PackedByteArray
	var reserved2:PackedByteArray
	var reserved:PackedByteArray
	
	static func deserialize(data_base64:String) -> House:
		var account_data:PackedByteArray = Marshalls.base64_to_raw(data_base64)
		
		var offset:int = 0
		var account_hash_value:int =  account_data.decode_u64(offset)
		print(account_hash_value)
		offset += 8
		if account_hash_value != ACCOUNT_DISCRIMINATOR:
			return null
		
		var house:House = House.new()
		
		house.house_id = account_data.slice(offset,offset+32)
		offset+=32
		house.house_admin = Pubkey.new_from_bytes(account_data.slice(offset,offset+32)) 
		offset+=32
		house.club_admin_collection = CH.CollectionIdentifier.deserialize(account_data,offset)
		offset+=33
		house.house_currency = Pubkey.new_from_bytes(account_data.slice(offset,offset+32)) 
		offset+=32
		house.clubs_created = account_data.decode_u16(offset)
		offset += 2
		house.member_count = account_data.decode_u32(offset)
		offset += 4
		house.house_config = CH.HouseConfig.deserialize(account_data,offset)
		offset += 66
		house.house_currency_decimals = account_data.decode_u8(offset)
		offset += 1
		
		var match_members_counted:bool = (account_data.decode_u8(offset) == 1)
		offset+=1
		if match_members_counted:
			house.members_per_match = account_data.decode_u8(offset)
			offset+=1
			
		house.reserved3 = account_data.slice(offset,offset+24)
		offset+=24
		house.reserved2 = account_data.slice(offset,offset+32)
		offset+=32
		house.reserved = account_data.slice(offset,offset+256)
		offset+=256
		
		return house
		
class CollectionIdentifier:
	var collection_key:Pubkey
	
	static func deserialize(data:PackedByteArray,initial_offset:int) -> CollectionIdentifier:
		var offset = initial_offset
		var identifier:CollectionIdentifier = CollectionIdentifier.new()
		#identify type currently not used, its for separating between creator address and collection key
		var identify_type:int = data.decode_u8(offset)
		offset += 1
		identifier.collection_key = Pubkey.new_from_bytes(data.slice(offset,offset+32))
		offset += 32
		
		#total offset = 1+32 = 33
		return identifier
		
class HouseConfig:
	var resolver_oracle:Pubkey
	var training_fallback_active:bool
	var club_tax_basis_points:int
	var club_creation_fee:int
	var match_time_limit_seconds:int
	var training_time_limit_seconds:int
	
	static func deserialize(data:PackedByteArray,initial_offset:int) -> HouseConfig:
		var offset = initial_offset
		var house_config:HouseConfig = HouseConfig.new()
		
		var oracle_exists:bool = (data.decode_u8(offset) == 1)
		offset += 1
		if oracle_exists:
			house_config.resolver_oracle = Pubkey.new_from_bytes(data.slice(offset,offset+32))
			offset+=32
			
		house_config.training_fallback_active = (data.decode_u8(offset) == 1)
		offset += 1
		house_config.club_tax_basis_points = data.decode_u64(offset)
		offset += 8
		house_config.club_creation_fee = data.decode_u64(offset)
		offset += 8
		house_config.match_time_limit_seconds = data.decode_s64(offset)
		offset += 8
		house_config.training_time_limit_seconds = data.decode_s64(offset)
		offset += 8
		
		#total offset: 1+32+1+8+8+8+8 = 66
		return house_config
		
		
		
		
	
		
		
		
		
