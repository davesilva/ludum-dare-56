extends Context
class_name TitleContext

const CONTEXT_ID = "context.title"

onready var start_button = $start_button

func context_id_string() -> String:
	return CONTEXT_ID


func _ready():
	start_button.connect("pressed", self, "_on_start_clicked")
	
	
func _on_start_clicked():
	_on_go_to_game_pressed()
	
	
func _on_go_to_game_pressed():
	print('hello')
	change_context(GameplayContext.CONTEXT_ID)
