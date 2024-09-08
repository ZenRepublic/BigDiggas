extends Node
class_name ClubhouseProgram

#for building custom program instructions, first goes function name, then array of accounts
#and then variables to pass in

#IMPORTANT:
#if no variables need to be passed in, write 'null'
#if multiple variables, put them in a dictionary
#if the variable is a class, pass it in as dictionary

@onready var anchor_program:AnchorProgram = $AnchorProgram

func get_pid() -> Pubkey:
		return Pubkey.new_from_string(anchor_program.get_pid())
	
func is_program_admin(account:Pubkey) -> bool:
	var wallet_admin_pda:Pubkey = ClubhousePDA.get_admin_proof_pda(account,get_pid())
	var account_info:Dictionary = await SolanaService.get_account_info(wallet_admin_pda)
	var data = account_info["result"]["value"]["data"][0]
	var admin_proof:CH.ProgramAdminProof = CH.ProgramAdminProof.deserialize(data)
	if admin_proof.wallet_address == null:
		return false
	return admin_proof.wallet_address.to_string() == SolanaService.wallet.get_pubkey().to_string()
	
func fetch_owned_houses(account:Pubkey) -> Array[CH.House]:
	return []
	
func get_house_by_name(house_name:String) -> CH.House:
	var house_pda:Pubkey = ClubhousePDA.get_house_pda(house_name,get_pid())
	var account_info:Dictionary = await SolanaService.get_account_info(house_pda)
	var data = account_info["result"]["value"]["data"][0]
	var house:CH.House = CH.House.deserialize(data)
	return house
	
