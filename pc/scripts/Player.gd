extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var id = null
var buttons = []
export var speed = 1.0

# Called when the node enters the scene tree for the first time.
func start(new_id):
	id = new_id
	WebSocket.connect("data_get", self, "_on_data_get")

func _on_data_get(data):
	if data.id == id:
		match (data.type):
			"leave":
				queue_free()
			"button":
				if not buttons.has(data.button):
					buttons.append(data.button)
				print(id + ": buttons -- " + String(buttons))
			"unbutton":
				if buttons.has(data.button):
					buttons.erase(data.button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var moveSpeed = speed
	if buttons.has("double"):
		moveSpeed *= 2
	if buttons.has("left"):
		rotate(Vector3(0, 1, 0), -delta * moveSpeed)
	if buttons.has("right"):
		rotate(Vector3(0, 1, 0), delta * moveSpeed)
