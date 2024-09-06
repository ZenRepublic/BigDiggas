extends WalletAsset
class_name Token

var decimals:int
var lamport_balance:int


func get_balance(fetch_new:bool=false) -> float:
	if decimals == 0:
		await SolanaService.get_token_decimals(mint.to_string())
	
	if lamport_balance == 0 or fetch_new:
		lamport_balance = await SolanaService.get_balance(SolanaService.wallet.get_pubkey().to_string(),mint.to_string())
		
	return float(lamport_balance)/(10**decimals)
	
