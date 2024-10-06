extends Context
class_name TitleContext

const CONTEXT_ID = "context.title"

onready var start_button = $start_button
onready var single_player_button = $single_player_button

func context_id_string() -> String:
	return CONTEXT_ID


func _ready():
	start_button.connect("pressed", self, "_on_start_clicked")
	single_player_button.connect("pressed", self, "_on_single_player_clicked")
	
	
func _on_start_clicked():
	_on_go_to_game_pressed()


func _on_single_player_clicked():
	Game.begin_single_player_game()


func _on_go_to_game_pressed():
	print('hello')
	change_context(LobbyContext.CONTEXT_ID)
