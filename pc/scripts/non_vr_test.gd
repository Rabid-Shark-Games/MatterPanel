extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var ws = false
export var speed: float = 1

var playerscene = preload("res://scenes/player.tscn")

var players = []
var ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if ws:
		WebSocket.connect_ws()
		WebSocket.connect("data_get", self, "_on_data_get")
		WebSocket.connect("connected", self, "_on_connected")

func _on_data_get(data):
	if data.type == "got_peers":
		print(data.peers)
		for x in data.peers.size():
			var newplayer = playerscene.instance()
			add_child(newplayer)
			newplayer.get_child(0).set_surface_material(0,newplayer.get_child(0).get_surface_material(0).duplicate())
			newplayer.get_child(0).get_surface_material(0).albedo_color = GlobalData.colors[x]
			newplayer.speed = speed
			newplayer.start(data.peers[x], $Path)
			newplayer.transform = $Path.transform
			players.push_back(newplayer)
			ids.push_back(data.peers[x])
	elif data.type == "player_join":
		var newplayer = playerscene.instance()
		add_child(newplayer)
		newplayer.get_child(0).set_surface_material(0,newplayer.get_child(0).get_surface_material(0).duplicate())
		newplayer.get_child(0).get_surface_material(0).albedo_color = GlobalData.colors[players.size()]
		newplayer.speed = speed
		newplayer.start(data.id, $Path)
		newplayer.transform = $Path.transform
		players.push_back(newplayer)
		ids.push_back(data.id)
	elif data.type == "leave":
		players.remove(ids.find(data.id))
		ids.erase(data.id)
		print(players)
	else:
		print(data)

func _on_connected():
	print("connected")
	WebSocket.send_data(JSON.print({
		"type": "start_game",
		"id": WebSocket.id
	}))
	WebSocket.send_data(JSON.print({
		"type": "get_peers",
		"id": WebSocket.id
	}))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	print("aaa")
