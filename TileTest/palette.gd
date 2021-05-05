extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var activeColorObject
var colorObjects = []
# Called when the node enters the scene tree for the first time.
func _ready():
	setActiveColorObject($Color0Area)
	colorObjects.append($Color0Area)
	colorObjects.append($Color1Area)
	colorObjects.append($Color2Area)
	colorObjects.append($Color3Area)
	print("Palette ready")
	
func setActiveColorObject(newColorObject):
	activeColorObject = newColorObject
	$SelectionIndicator.position.x = activeColorObject.position.x
	$"..".get_node("ColorPicker").set_pick_color(activeColorObject.currentColor)

func modifyActiveColor(newColor):
	activeColorObject.set_color(newColor)
	
func getActiveColorValue():
	return activeColorObject.currentColor
	
func loadColor(index, color):
	colorObjects[0].set_color(color)

func _on_ColorPicker_color_changed(color):
	var convertedColor = Color8(color.r*255, color.g*255, color.b*255, color.a*255)
	activeColorObject.set_color(convertedColor)
	var index = colorObjects.find(activeColorObject, 0)
	$"../..".activePaletteColors = $"../..".activePaletteColorCollection[index]
	$"../../EditableSprite".updateImage()
