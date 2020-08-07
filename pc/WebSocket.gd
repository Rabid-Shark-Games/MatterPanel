extends Node

export var websocket_url = "ws://localhost:8080/api"
# export var websocket_url = "ws://echo.websocket.org"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var id = null

signal data_get(data)
signal connected

func connect_ws():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	#print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())
	var packet = _client.get_peer(1).get_packet().get_string_from_utf8()
	if JSON.parse(packet).result.type == "id":
		id = JSON.parse(packet).id
		emit_signal("connected")
	else:
		emit_signal("data_get", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
