extends Control

#the current number of tiles
var numTiles = 1
#the current number of palettes
var numPalettes = 1

var remainingTiles = 254
var remainingPalettes = 63

#a list holding arrays of pixel data stored as int[]s. each tile is 8x8
var pixelDataCollection = []
#a list holding arrays of color8s. 4 colors per pal
var colorPaletteCollection = []
#a list holding the selected palette for each tile
var defaultColors = []
#a list holding the resolution of each tile, to support metatiles
var resolutions = []
#the currently active tile index
var activeTileIndex = 0
#the currently active color palette
var activePaletteIndex = 0
#the currently active color in the palette
var activeColorIndex = 0

#used to make inactive tiles gray, because updating every single necessary
#tile whenever a palette changes is pretty costly. Resetting the flag
#will allow this behavior, but i can see framerate drops and a huge 
#cpu usage spike 
var inactiveTilesShownAsGray = true
var grayPalette = [Color8(255, 255, 255, 255), Color8(168,168,168,255), 
					Color8(84, 84, 84, 255), Color8(0,0,0,255)]

#ui element references
onready var editableSprite = $EditableSprite
onready var colorPicker = $ColorPicker
onready var hbox = $TileScroller/HBoxContainer
onready var vbox = $PaletteScroller/VBoxContainer
onready var tileSizeDropdown = $TileSizeDropdown
var tileSelectors = []
var paletteSelectors = []
var colorRects = []

#resource references
var defaultMat
var selectedMat = load("res://selectedmat.tres")
var eightbyeight = load("res://eight.png")
var onebyfour = load("res://graypalette.png")

#flag for letting the sprite be edited even while holding
var clickingEditableSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	import_file("user://text.txt")
	#set up ui
	editableSprite.expand = true
	editableSprite.rect_min_size = Vector2(500, 500)
	#create tile selectors
	hbox.add_constant_override("separation", 8)
	#create a texture rect and add it to the tile selectors
	if (len(pixelDataCollection) == 0):
		addTile(Vector2(8,8))
	#else process the data from the file
	else:
		for i in range(len(pixelDataCollection)):
			var res = resolutions[i]
			var image = Image.new()
			image.create(res.x, res.y,false, Image.FORMAT_RGBA8)
			image.lock()
			var pixelData = pixelDataCollection[i]
			for x in range(res.x):
				for y in range(res.y): 
					var pixel = pixelData[x + (y*res.y)]
					image.set_pixel(x, y, grayPalette[pixel])
			image.unlock()
			defaultColors.append(0)
			var textureRect = TextureRect.new()
			var texture = ImageTexture.new()
			texture.create_from_image(image, Texture.FLAG_REPEAT)
			textureRect.set_texture(texture)
			textureRect.expand = true
			textureRect.rect_min_size = Vector2(64, 64)
			textureRect.connect("gui_input", self, "tileClicked", [i])
			tileSelectors.append(textureRect) 
			hbox.add_child(textureRect)
			hbox.move_child(textureRect, numTiles-1)
			numTiles = numTiles + 1
	#get the default mat so we can change it back when a selection goes inactive
	defaultMat = tileSelectors[0].material
	if (len(colorPaletteCollection) == 0):
		addPalette()
		paletteSelectors[0].material = selectedMat
	else:
		for i in range(len(colorPaletteCollection)):
			var image = Image.new()
			image.create(4,1,false, Image.FORMAT_RGBA8)
			image.lock()
			var colors = colorPaletteCollection[i]
			for j in range(4):
				image.set_pixel(j, 0, colors[j])
			image.unlock()
			var textureRect = TextureRect.new()
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			textureRect.set_texture(texture)
			textureRect.texture.set_flags(0)
			textureRect.expand = true
			textureRect.rect_min_size = Vector2(64, 32)
			textureRect.connect("gui_input", self, "paletteClicked", [numPalettes - 1])
			paletteSelectors.append(textureRect)
			vbox.add_child(textureRect)
			vbox.move_child(textureRect, numPalettes-1)
			numPalettes = numPalettes + 1
		#select the default color palette for tile 0
		paletteSelectors[activePaletteIndex].material = defaultMat
		activePaletteIndex = defaultColors[0]
		paletteSelectors[activePaletteIndex].material = selectedMat
	
	#set tile 0 to the selected tile
	tileSelectors[0].material = selectedMat
	#create palette selectors
	vbox = $PaletteScroller/VBoxContainer
	vbox.add_constant_override("separation", 8)
	#set up color rects
	colorRects.append($ColorRectParent/Color1)
	colorRects.append($ColorRectParent/Color2)
	colorRects.append($ColorRectParent/Color3)
	colorRects.append($ColorRectParent/Color4)
	#this is only really necessary if we've loaded in data to begin with
	refresh_sprite()
	refresh_palette()
	
func addTile(res):
	var tilesConsumed = ((res.x * res.y) / (8*8))
	if (remainingTiles - tilesConsumed < 0):
		print("Not enough tiles left in this tileset to create a new tile with the given resolution")
		return
	remainingTiles = remainingTiles - tilesConsumed
	resolutions.append(res)
	pixelDataCollection.append([])
	var image = Image.new()
	image.create(res.x, res.y,false, Image.FORMAT_RGBA8)
	image.lock()
	for x in range(res.x):
		for y in range(res.y):
			pixelDataCollection[numTiles-1].append(0)
			image.set_pixel(x, y, Color8(255,255,255,255))
	image.unlock()
	defaultColors.append(0)
			
	var textureRect = TextureRect.new()
	var texture = ImageTexture.new()
	texture.create_from_image(image, Texture.FLAG_REPEAT)
	textureRect.set_texture(texture)
	textureRect.expand = true
	textureRect.rect_min_size = Vector2(64, 64)
	textureRect.connect("gui_input", self, "tileClicked", [numTiles - 1])
	tileSelectors.append(textureRect) 
	hbox.add_child(textureRect)
	numTiles = numTiles + 1
	
	print("%d tiles remaining" % remainingTiles)
	
func addPalette():
	colorPaletteCollection.append([])
	for i in range(4):
		colorPaletteCollection[numPalettes-1].append(grayPalette[i])
	var textureRect = TextureRect.new()
	textureRect.set_texture(onebyfour)
	textureRect.texture.set_flags(0)
	textureRect.expand = true
	textureRect.rect_min_size = Vector2(64, 32)
	textureRect.connect("gui_input", self, "paletteClicked", [numPalettes - 1])
	paletteSelectors.append(textureRect)
	vbox.add_child(textureRect)
	numPalettes = numPalettes + 1
	
func _process(delta):
	if not Input.is_action_pressed("click"):
		clickingEditableSprite = false
	if (clickingEditableSprite):
		#find the displacement relative to the editablesprite
		var displacementX = get_global_mouse_position().x - editableSprite.rect_position.x
		var displacementY = get_global_mouse_position().y - editableSprite.rect_position.y
		#normalize and then scale to tile size
		var resolution = resolutions[activeTileIndex]
		var pixelX = int((displacementX / editableSprite.rect_size.x) * resolution.x)
		var pixelY = int((displacementY / editableSprite.rect_size.y) * resolution.y)
		if (pixelX < resolution.x and pixelY < resolution.y and pixelX > -1 and pixelY > -1):
			edit_tile(pixelX, pixelY)
			refresh_sprite()
		
func edit_tile(pixelX, pixelY):
	var resolution = resolutions[activeTileIndex]
	pixelDataCollection[activeTileIndex][pixelX + (pixelY*resolution.y)] = activeColorIndex
	
#this is called when:
#	a color is edited
#	a pixel is edited
#	the active tile is changed
func refresh_sprite():
	var resolution = resolutions[activeTileIndex]
	var spriteTex = Image.new()
	spriteTex.create(resolution.x, resolution.y, false, Image.FORMAT_RGBA8)
	spriteTex.lock()
	var pixels = pixelDataCollection[activeTileIndex]
	var palette = colorPaletteCollection[activePaletteIndex]
	var pixel = 0
	var color = Color8(255,255,255,255)
	for x in range(resolution.x):
		for y in range(resolution.y):
			pixel = pixels[x + (y*resolution.y)]
			color = palette[pixel]
			spriteTex.set_pixel(x, y, color)
	spriteTex.unlock()
	var imageTex = ImageTexture.new()
	imageTex.create_from_image(spriteTex, 0)
	editableSprite.set_texture(imageTex)
	tileSelectors[activeTileIndex].set_texture(imageTex)
	
#this is called when:
#	a color is edited
#	a new palette is selected
func refresh_palette():
	var paletteTex = paletteSelectors[activePaletteIndex].texture.get_data()
	paletteTex.lock()
	var colors = colorPaletteCollection[activePaletteIndex] 
	for x in range(4):
		paletteTex.set_pixel(x, 0, colors[x])
		colorRects[x].color = colors[x]
	paletteTex.unlock()
	var imageTex = ImageTexture.new()
	imageTex.create_from_image(paletteTex, 0)
	paletteSelectors[activePaletteIndex].set_texture(imageTex)
	var activeColorRect = colorRects[activeColorIndex]
	var colorsArray = colorPaletteCollection[activePaletteIndex]
	activeColorRect.color = colorsArray[activeColorIndex]
	#refresh all the tiles that use this palette since their colors just changed
	if (not inactiveTilesShownAsGray):
		for i in range(numTiles):
			if defaultColors[i] == activePaletteIndex:
				var tileTex = tileSelectors[i].texture.get_data()
				tileTex.lock()
				var pixels = pixelDataCollection[i]
				for x in range(8):
					for y in range(8):
						var pixel = pixels[x + (y*8)]
						var color = colors[pixel]
						tileTex.set_pixel(x, y, color)
				tileTex.unlock()
				imageTex = ImageTexture.new()
				imageTex.create_from_image(tileTex, 0)
				tileSelectors[i].set_texture(imageTex)
	
func tileClicked(event, index):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		tileSelectors[activeTileIndex].material = defaultMat
		#make newly inactive tile gray
		if (inactiveTilesShownAsGray):
			var tileTex = tileSelectors[activeTileIndex].texture.get_data()
			tileTex.lock()
			var pixels = pixelDataCollection[activeTileIndex]
			var resolution = resolutions[activeTileIndex]
			for x in range(resolution.x):
				for y in range(resolution.y):
					var pixel = pixels[x + (y*resolution.y)]
					var color = grayPalette[pixel]
					tileTex.set_pixel(x, y, color)
			tileTex.unlock()
			var imageTex = ImageTexture.new()
			imageTex.create_from_image(tileTex, 0)
			tileSelectors[activeTileIndex].set_texture(imageTex)
		activeTileIndex = index
		tileSelectors[activeTileIndex].material = selectedMat
		paletteSelectors[activePaletteIndex].material = defaultMat
		activePaletteIndex = defaultColors[activeTileIndex]
		paletteSelectors[activePaletteIndex].material = selectedMat
		refresh_palette()
		refresh_sprite()

func paletteClicked(event, index):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		paletteSelectors[activePaletteIndex].material = defaultMat
		activePaletteIndex = index
		paletteSelectors[activePaletteIndex].material = selectedMat
		defaultColors[activeTileIndex] = activePaletteIndex
		refresh_palette()
		refresh_sprite()

func _on_ColorPicker_color_changed(color):
	var colors = colorPaletteCollection[activePaletteIndex]
	colors[activeColorIndex] = Color8(color.r*255, color.g*255, color.b*255, 255)
	refresh_palette()
	refresh_sprite()

func _on_EditableSprite_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		clickingEditableSprite = true

func _on_Color1_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		activeColorIndex = 0


func _on_Color2_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		activeColorIndex = 1

func _on_Color3_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		activeColorIndex = 2

func _on_Color4_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		activeColorIndex = 3

var supportedTileSizes = [Vector2(8,8), Vector2(16,16), Vector2(32,32), Vector2(64,64), Vector2(128, 128)]
func _on_AddTileButton_button_down():
	#get tile size from dropdown
	var tileSize = supportedTileSizes[tileSizeDropdown.selected]
	addTile(tileSize)

func _on_AddPaletteButton_button_down():
	addPalette()

func _on_ExportButton_button_down():
	var output = "This is a multipurpose file. Everything before the tilde is used by the editors, while everything after the tilde is the same data, but encoded for the console. The assembler understands to discard everything before the tilde, and the editors understand to discard everything after it.\n\n"
	output += "resolutions: \n"
	for resolution in resolutions: 
		output+= "%d, " % resolution.x
	#remove trailing comma
	output.erase(output.length() - 2, 2)
	output += "\n\nTiles: \n"
	for tileIndex in range(numTiles-1):
		var pixelData = pixelDataCollection[tileIndex]
		for pixel in pixelData:
			output += "%d, " % pixel
		#remove trailing comma
		output.erase(output.length() - 2, 2)
		output += "\n"
	output += "\n\npalettes:\n"
	
	for palette in colorPaletteCollection:
		for color in palette:
			output += "%f, %f, %f;" % [color.r, color.g, color.b]
		#remove trailing semicolon
		output.erase(output.length()-1, 1)
		output+="\n"
		
	output+= "\n\ndefaultColors:\n"
	for value in defaultColors:
		output += "%d, " % value
	#remove trailing comma
	output.erase(output.length()-2, 2)
	
	#write assembler output
	output += "\n~\n"
	output += "PixelsBegin:\n"
	output += "DB "
	#todo get metatiles working
	#for each tile
	for tile in pixelDataCollection:
		#get 4 pixels at a time
		for i in range(len(tile) / 4):
			var offset = i * 4
			var pixel0 = tile[offset]
			var pixel1 = tile[offset + 1]
			var pixel2 = tile[offset + 2]
			var pixel3 = tile[offset + 3]
			var encodedPixel = 0
			encodedPixel |= pixel0 << 6
			encodedPixel |= pixel1 << 4
			encodedPixel |= pixel2 << 2
			encodedPixel |= pixel3
			output += "$%02X, " % encodedPixel
	#remove trailing comma
	output.erase(output.length()-2, 2)
	
	var file = File.new()
	file.open("user://text.txt", File.WRITE)
	file.store_string(output)
	file.close()
	
func import_file(url):
	#return
	var inputFile = File.new()
	if not inputFile.file_exists(url):
		return
	inputFile.open(url, File.READ)
	var mode = ""
	while !(inputFile.eof_reached()):
		var line = inputFile.get_line()
		if (mode == "resolution"):
			var values = line.split(",")
			for value in values:
				var intvalue = int(value)
				resolutions.append(Vector2(intvalue, intvalue))
			mode = ""
		if (mode == "tile"):
			if (line == ""):
				mode = ""
			var values = line.split(",")
			var pixelData = []
			for value in values:
				pixelData.append(int(value))
			if (len(pixelData) > 1):
				pixelDataCollection.append(pixelData)
		if (mode == "palette"):
			if (line == ""):
				mode = ""
			else:
				var colorText = line.split(";")
				var paletteData = []
				for color in colorText:
					var palette = []
					for rgbValue in color.split(","):
						palette.append(int(float(rgbValue) * 255))
					var decodedColor = Color8(palette[0], palette[1], palette[2], 255)
					paletteData.append(decodedColor)
				if (len(paletteData) > 1):
					colorPaletteCollection.append(paletteData)
		if (mode == "defaultcolors"):
			if (line == ""):
				mode = ""
			var values = line.split(",")
			for value in values:
				defaultColors.append(int(value))
			
		if ("resolutions" in line):
			mode = "resolution"
		elif ("Tiles" in line):
			mode = "tile"
		elif ("palettes" in line):
			mode = "palette"
		elif ("defaultColors" in line):
			mode = "defaultcolors"
		elif ("~" in line):
			mode = "done"
			
	var contents = inputFile.get_as_text()
	pass
