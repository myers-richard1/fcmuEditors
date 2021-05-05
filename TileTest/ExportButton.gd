extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_down():
	print("Exporting...")
	var outputData = ""
	var Editable = $"../../EditableSprite"
	var colorData = Editable.colorData
	var byteArray = PoolByteArray()
	for i in range(64): 
		byteArray.append(colorData[i])
	print(byteArray.hex_encode())
	return
	print("Data: " + outputData)
	var outputFile = File.new()
	outputFile.open("user://tiles.txt", File.WRITE)
	outputFile.store_line(outputData)
	outputFile.close()
