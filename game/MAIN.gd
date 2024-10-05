extends Node
class_name Main

export (PackedScene) var title_context_scene
export (PackedScene) var lobby_context_scene
export (PackedScene) var gameplay_context_scene

onready var context_root = $context_root

func _ready():
	randomize()
	Game.initialize_services()
	_set_up_contexts()
	Game.context_service.go_to(TitleContext.CONTEXT_ID)


func _set_up_contexts():
	# wire up the preloaded scenes
	var context_scene_dictionary = { 
		TitleContext.CONTEXT_ID : title_context_scene, 
		GameplayContext.CONTEXT_ID : gameplay_context_scene,
		LobbyContext.CONTEXT_ID : lobby_context_scene
	}
	
	Game.context_service.context_root = context_root
	Game.context_service.load_with_context_scene_dictionary(context_scene_dictionary)
	
	
