extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("8x8")
	add_item("16x16")
	add_item("32x32")
	add_item("64x64")
	add_item("128x128")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
