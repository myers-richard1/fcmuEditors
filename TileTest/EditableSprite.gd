extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var editableImage
var texture

var colorData
var colorDataCollection = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.scale = self.scale
	editableImage = Image.new()
	editableImage.create(8,8, false, Image.FORMAT_RGBA8)
	editableImage.lock()
	for z in range (256):
		colorData = []
		colorDataCollection.append(colorData)
		for x in range(8):
			for y in range(8):
				#
				colorData.append(0)
	for x in range(8):
		for y in range(8):
			editableImage.set_pixel(x, y, Color8(255,255,255,255))
	colorData = colorDataCollection[0]
	editableImage.unlock()
	texture = ImageTexture.new()
	texture.create_from_image(editableImage, Texture.FLAG_REPEAT)
	$Sprite.set_texture(texture)
	clicking = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not Input.is_action_pressed("click")):
		clicking = false
	if (clicking):
		#editImage()
		updateImage()
	pass

var clicking

func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed()):
		clicking = true
		

		
func updateImage():
	#find displacement
	editableImage = $Sprite.texture.get_data()
	editableImage.lock()
	for x in range(8):
		for y in range(8):
			editableImage.set_pixel(x, y, 
			$"../UIRoot/Palette".colorObjects[colorData[x + (y*8)]].currentColor)
	editableImage.unlock()
	texture = ImageTexture.new()
	texture.create_from_image(editableImage, Texture.FLAG_REPEAT)
	$Sprite.set_texture(texture)
	$"../UIRoot".activeTile.set_texture(texture)
	
func setActiveColorData(index):
	colorData = colorDataCollection[index]
	updateImage()
	
