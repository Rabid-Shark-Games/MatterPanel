extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	WebSocket.connect_ws()
	WebSocket.connect("data_get", self, "_on_data_get")
	WebSocket.connect("connected", self, "_on_connected")

func _on_data_get(data):
	if data.type == "got_peers":
		for peer in data.peers:
			var player = $MeshInstance.duplicate()
			add_child(player)
			player.visible = true
			player.name = peer
			player.start(peer)
	else:
		print(data)

func _on_connected():
	WebSocket.send_data(JSON.print({
		"type": "start_game",
		"id": WebSocket.id
	}))
	WebSocket.send_data(JSON.print({
		"type": "get_peers",
		"id": WebSocket.id
	}))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
