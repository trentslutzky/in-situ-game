extends ItemList

func _ready():
	connect("mouse_entered",self,"_mouse_entered")
	connect("mouse_exited",self,"_mouse_exited")
	
func _mouse_entered():
	get_parent().mouse_entered()

func _mouse_exited():
	get_parent().mouse_exited()
