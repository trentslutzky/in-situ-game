extends Control

onready var item_list = $ItemList

onready var GOManager = get_node('/root/Game/GameObjects')
onready var InputManager = get_node('/root/Game/InputManager')

var mouse_in = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var items = GOManager.gameobject_data
	for item in items:
		print(item)
		item_list.add_item(item['title'],load(item['sprite']),true)

func _on_ItemList_item_selected(index):
	InputManager.is_placing = true
	GOManager.set_selected_object(index)

func mouse_entered():
	print('mouse enter')
	mouse_in = true
	
func mouse_exited():
	print('mouse leave')
	mouse_in = false
