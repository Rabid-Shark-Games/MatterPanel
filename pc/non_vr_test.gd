extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var ws = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if ws:
		WebSocket.connect_ws()
		WebSocket.connect("data_get", self, "_on_data_get")
		WebSocket.connect("connected", self, "_on_connected")

func _on_data_get(data):
	print(data)

func _on_connected():
	WebSocket.send_data(JSON.print({
		"type": "get_peers",
		"id": WebSocket.id
	}))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
