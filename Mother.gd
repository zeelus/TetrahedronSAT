
extends Node
var time = 10.0
 
func _ready():
	pass
 
func _physics_process(delta):
	for nodeA in get_children():
		for nodeB in get_children():
			if nodeA > nodeB:
 
				for axA in [nodeA.get_local_direction('x'), nodeA.get_local_direction('y'), nodeA.get_local_direction('z')]:
					if supportFunc(nodeA, nodeB, axA):
						return
					for axB in [nodeB.get_local_direction('x'), nodeB.get_local_direction('y'), nodeB.get_local_direction('z')]:
						if supportFunc(nodeA, nodeB, axA.cross(axB).normalized()):
							return
				for axB in [nodeB.get_local_direction('x'), nodeB.get_local_direction('y'), nodeB.get_local_direction('z')]:
					if supportFunc(nodeA, nodeB, axB):
						return
 
				nodeA.isStatic = true
				nodeB.isStatic = true
 
func _process(delta):
	if time > 3:
		time = 0.0
	time += delta
 
# wykrycie przekrycia
 
func supportFunc(boxA, boxB, t):
	var boxAMinVal = boxA.position.dot(t) - abs(boxA.get_local_direction('x').dot(t)) - abs(boxA.get_local_direction('y').dot(t)) - abs(boxA.get_local_direction('z').dot(t))
	var boxAMaxVal = boxA.position.dot(t) + abs(boxA.get_local_direction('x').dot(t)) + abs(boxA.get_local_direction('y').dot(t)) + abs(boxA.get_local_direction('z').dot(t))
 
	var boxBMinVal = boxB.position.dot(t) - abs(boxB.get_local_direction('x').dot(t)) - abs(boxB.get_local_direction('y').dot(t)) - abs(boxB.get_local_direction('z').dot(t))
	var boxBMaxVal = boxB.position.dot(t) + abs(boxB.get_local_direction('x').dot(t)) + abs(boxB.get_local_direction('y').dot(t)) + abs(boxB.get_local_direction('z').dot(t))
 
	if boxAMinVal < boxBMinVal:
		return boxAMaxVal < boxBMinVal
	else:
		return boxBMaxVal < boxAMinVal