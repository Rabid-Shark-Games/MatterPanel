extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var id = null
var buttons = []
export var speed = 1.0
var currentpath: Spatial
var movespeed = 0
var movecomplete = true
var newpath: Spatial
var movepercent = 0

# Called when the node enters the scene tree for the first time.
func start(new_id, pathstart):
	id = new_id
	WebSocket.connect("data_get", self, "_on_data_get")
	currentpath = pathstart

func _on_data_get(data):
	if data.id == id:
		match (data.type):
			"leave":
				queue_free()
			"button":
				if movecomplete:
					var node = null
					if data.button == "up":
						node = currentpath.get_node(currentpath.north)
					elif data.button == "down":
						node = currentpath.get_node(currentpath.south)
					elif data.button == "left":
						node = currentpath.get_node(currentpath.west)
					elif data.button == "right":
						node = currentpath.get_node(currentpath.east)
					if node != null:
						start_move(node)
			"unbutton":
				pass
				#if buttons.has(data.button):
				#	buttons.erase(data.button)

func start_move(next):
	movecomplete = false
	movepercent = 0
	movespeed = .02/currentpath.global_transform.origin.distance_to(next.global_transform.origin)
	newpath = next

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	var moveSpeed = speed
#	if buttons.has("double"):
#		moveSpeed *= 2
#	
#	if buttons.has("left"):
#		pass
#	if buttons.has("right"):
#		pass

func _process(delta):
	if !movecomplete:
		if movepercent >= 1:
			movecomplete = true
			movepercent = 0
			if !newpath.main_node:
				currentpath = newpath
				start_move(currentpath.get_node(currentpath.non_main_next))
			else:
				currentpath = newpath
		else:
			movepercent += movespeed
			global_transform.origin = lerp(currentpath.global_transform.origin,newpath.global_transform.origin,movepercent)
