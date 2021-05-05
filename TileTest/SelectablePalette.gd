extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var index


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		$"../../..".activePalette = self
		$"../../..".activePaletteIndex = index
		$"../../..".loadPalette(index)
		$"../../..".updateColorData()
