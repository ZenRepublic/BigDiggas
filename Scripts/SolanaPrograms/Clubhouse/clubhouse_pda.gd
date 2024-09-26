extends Node
class_name ClubhousePDA

static var PROGRAM_ID:Pubkey = Pubkey.new_from_string("C1ubCwnK75ExARi8BoVzAvREDG29wJKyiwnf1hC8rgBU")
	
static func get_house_pda(house_name:String) -> Pubkey:
	var name_bytes = "house".to_utf8_buffer()
	var house_name_bytes = house_name.to_utf8_buffer()
	return Pubkey.new_pda_bytes([name_bytes,house_name_bytes],PROGRAM_ID)

static func get_house_currency_vault(house_pda:Pubkey) -> Pubkey:
	return Pubkey.new_pda_bytes([house_pda.to_bytes()],PROGRAM_ID)
	
static func get_campaign_pda(campaign_name:String,house_pda:Pubkey) -> Pubkey:
	var name_bytes = "campaign".to_utf8_buffer()
	var campaign_name_bytes = campaign_name.to_utf8_buffer()
	return Pubkey.new_pda_bytes([name_bytes,campaign_name_bytes,house_pda.to_bytes()],PROGRAM_ID)
	
static func get_campaign_vault_pda(campaign_pda:Pubkey) -> Pubkey:
	var name_bytes = "rewards".to_utf8_buffer()
	return Pubkey.new_pda_bytes([name_bytes,campaign_pda.to_bytes()],PROGRAM_ID)
	
static func get_campaign_player_pda(campaign_pda:Pubkey,player_mint:Pubkey) -> Pubkey:
	var name_bytes = "campaign_player_stats".to_utf8_buffer()
	return Pubkey.new_pda_bytes([name_bytes,campaign_pda.to_bytes(),player_mint.to_bytes()],PROGRAM_ID)
	
static func get_nft_metadata_pda(nft:Pubkey) -> Pubkey:
	var name_bytes = "metadata".to_utf8_buffer()
	var metadata_pid_seed:PackedByteArray = SolanaUtils.bs58_decode(SolanaService.TOKEN_METADATA_PID)
	return Pubkey.new_pda_bytes([name_bytes,metadata_pid_seed,nft.to_bytes()],Pubkey.new_from_string(SolanaService.TOKEN_METADATA_PID))
