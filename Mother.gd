
extends Node
var time = 10.0
# wieszkołki w układzie lokalnym przed obrotem kwateriona.
var modelVertex = [
Vector3(-0.47140, 0.81650, -0.33333),
Vector3(0.94281, 0.0, -0.33333),
Vector3(-0.47140, -0.81650, -0.33333),
Vector3(0.0, 0.0, 1.00),
]

var vectorP = []
var vectorK = []
 
func _ready():
	self.vectorP = getVectorP()
	self.vectorK = getVectorK()
 
func _physics_process(delta):
	
	for nodeA in get_children():
		for nodeB in get_children():
			var analizeOS = []
			for vector in self.vectorP:
				analizeOS.append(nodeA.rotation_representation.xform(vector))
				analizeOS.append(nodeB.rotation_representation.xform(vector))
			
			for vectorA in self.vectorK:
				var nodeAVector = nodeA.rotation_representation.xform(vectorA)
				for vectorB in self.vectorK:
					var nodeBVector = nodeA.rotation_representation.xform(vectorA)
					analizeOS.append(nodeAVector.cross(nodeBVector))
			print(len(analizeOS))
			
 
func _process(delta):
	if time > 3:
		time = 0.0
	time += delta
	
# zwaraca vektory scian w układzie lokalnym
func getVectorP():
	var vectores = []
	vectores.append(modelVertex[0].cross(modelVertex[1]))
	vectores.append(modelVertex[0].cross(modelVertex[3]))
	vectores.append(modelVertex[1].cross(modelVertex[3]))
	vectores.append(modelVertex[2].cross(modelVertex[3]))
	
	return vectores
# zwaraca vektory krawędzi w układzie lokalnym
func getVectorK():
	var vectores = []
	vectores.append(modelVertex[0] - modelVertex[1])
	vectores.append(modelVertex[1] - modelVertex[2])
	vectores.append(modelVertex[2] - modelVertex[0])
	
	vectores.append(modelVertex[3] - modelVertex[0])
	vectores.append(modelVertex[3] - modelVertex[1])
	vectores.append(modelVertex[3] - modelVertex[2]) 
	return vectores
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