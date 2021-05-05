extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currentColor = Color8(255,255,255,255)
var image
var texture

# Called when the node enters the scene tree for the first time.
func _ready():
	image = Image.new()
	image.create(1,1, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.new()
	set_color(currentColor)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT):
		get_parent().setActiveColorObject(self)
		
func set_color(color):
	currentColor = color
	image.lock()
	image.set_pixel(0,0, currentColor)
	image.unlock()
	texture.create_from_image(image, Texture.FLAG_REPEAT)
	$Color.set_texture(texture)
	
	
