extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var EditableSpriteNode #the actual node displaying the sprite being drawn
var pixelData #the color IDs of the currently active tile
var pixelDataCollection #the color IDs of all the tiles in the tileset

var activeTileIndex #the index of the currently active tile
var activePaletteIndex #the index of the currently active color palette

var colorPalettes #the list holding the palettes (each palette has 4 colors)

#flag for whether the user is clicking the editable sprite
var clicking

# Called when the node enters the scene tree for the first time.
func _ready():
	#prep the image for the selectable tiles
	var image = Image.new()
	image.create(8,8, false, Image.FORMAT_RGBA8)
	image.lock()
	for x in range(8):
		for y in range(8):
			image.set_pixel(x, y, Color8(255,255,255,255))
	image.unlock()
	var texture = ImageTexture.new()
	texture.create_from_image(image, Texture.FLAG_REPEAT)
	activeTileIndex = 0
	for i in range(256):
		var selectableTile = load("res://SelectableTile.tscn").instance()
		selectableTile.index = i
		selectableTile.set_texture(texture)
		var textureRect = selectableTile
		$TileScroller/TileSelector.add_child(selectableTile)
		$TileScroller.mouse_filter = Control.MOUSE_FILTER_PASS
		textureRect.rect_min_size = Vector2(64,64)
		textureRect.expand = true
	#palette stuff
	image = Image.new()
	image.create(4, 1, false, Image.FORMAT_RGBA8)
	image.lock()
	for i in range(4):
		 image.set_pixel(i, 0, Color8(255, 255, 255, 255))
	image.unlock()
	colorPalettes = []
	for i in range(64):
		var colorPalette = []
		for j in range (4):
			activePaletteColors.append(Color8(255,255,255,255))
		activePaletteColorCollection.append(activePaletteColors)
		var textureRect = load("res://SelectablePalette.tscn").instance()
		textureRect.index = i
		textureRect.set_texture(texture)
		$PaletteScroller/PaletteSelector.add_child(textureRect)
		textureRect.rect_min_size = Vector2(64, 16)
		textureRect.expand = true
	activePaletteIndex = 0
	
func editImage():
	var displacement = Vector2(0,0)
	var shapeWidth = $CollisionShape2D.shape.extents.x * self.scale.x
	var shapeHeight = $CollisionShape2D.shape.extents.y * self.scale.y
	displacement.x = get_global_mouse_position().x - self.position.x + shapeWidth
	displacement.y = get_global_mouse_position().y - self.position.y + shapeWidth
	var pixelWidth = shapeWidth * 2 / 8
	var pixelX = displacement.x / pixelWidth
	pixelX = int(pixelX)
	var pixelY = displacement.y / pixelWidth
	pixelY = int(pixelY)
	if (pixelX > 7 or pixelY > 7):
		return
	var activeColorObject = $"../UIRoot/Palette".activeColorObject
	var colorIndex = $"../UIRoot/Palette".colorObjects.find(activeColorObject)
	colorData[pixelX + (pixelY * 8)] = colorIndex

func updateColorData():
	$"../EditableSprite".setActiveColorData(activeTileIndex)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func loadPalette(index):
	activePaletteColors = activePaletteColorCollection[index]
	$"Palette".loadColor(0, activePaletteColors[0])
	$"Palette".loadColor(1, activePaletteColors[1])
	$"Palette".loadColor(2, activePaletteColors[2])
	$"Palette".loadColor(3, activePaletteColors[3])
	
