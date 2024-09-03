extends Node

@export var clubhouse_program:ClubhouseProgram
# Called when the node enters the scene tree for the first time.
func _ready():
	SolanaService.wallet.on_login_finish.connect(test_function)
	SolanaService.wallet.try_login()
	pass


func test_function(success:bool) -> void:
	if !success:
		print("FAILED TO LOGIN")
		return
		
	var wallet_address:Pubkey = SolanaService.wallet.get_pubkey()
	#var is_admin:bool = await clubhouse_program.is_program_admin(wallet_address)
	var house:CH.House = await clubhouse_program.get_house_by_name("ForeseeEZ")
	print(house.house_admin.to_string())
