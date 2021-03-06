
extends Node
var time = 10.0
# wieszkołki w układzie lokalnym modelu.
var modelVertex = [
Vector3(-0.47140, 0.81650, -0.33333),
Vector3(0.94281, 0.0, -0.33333),
Vector3(-0.47140, -0.81650, -0.33333),
Vector3(0.0, 0.0, 1.00),
]

var vectorP = []
var vectorK = []

onready var nodeA = $"A"
onready var nodeB = $"B"

var previousSETos = generateZeros(44)

 
func _ready():
	self.vectorP = getVectorP()
	self.vectorK = getVectorK()
	
	self.nodeA.velocity = Vector3(-5.0, 0.0, 0.0);
	self.nodeB.velocity = Vector3(5.0, 0.0, 0.0);

 
func _physics_process(delta):
	var analizeOS = []
	var nodeAVertex = []
	var nodeBVertex = []
			
	for mVertex in self.modelVertex:
		nodeAVertex.append(nodeA.rotation_representation.xform(mVertex) + nodeA.position)
		nodeBVertex.append(nodeB.rotation_representation.xform(mVertex) + nodeB.position)
			
	for vector in self.vectorP:
		analizeOS.append(nodeA.rotation_representation.xform(vector).normalized())
		analizeOS.append(nodeB.rotation_representation.xform(vector).normalized())
			
	for vectorA in self.vectorK:
		var nodeAVector = nodeA.rotation_representation.xform(vectorA)
		for vectorB in self.vectorK:
			var nodeBVector = nodeA.rotation_representation.xform(vectorB)
			var cross = nodeAVector.cross(nodeBVector).normalized()
			analizeOS.append(cross)
			
	var SETos = generateZeros(44)
	var i = 0
	for os in analizeOS:
		if self.supportFunc(nodeAVertex, nodeBVertex, os):
			SETos[i] = 0
		else:
			SETos[i] = 1
		i = i + 1
	
	if SETos.find(0) == -1:
		self.detectTouch(delta, analizeOS)
	self.previousSETos = SETos
	
func detectTouch(delta, analizeOS):
	var index = self.previousSETos.find(0)
	if index != -1:
		var OS = analizeOS[index]
		nodeA.velocity = nodeA.velocity + (nodeA.velocity * nodeA.velocity.dot(OS))
		nodeB.velocity = nodeA.velocity - (nodeA.velocity * nodeB.velocity.dot(OS))
		nodeA.isNew = true
		nodeB.isNew = true
	

 
func _process(delta):
	if time > 3:
		time = 0.0
	time += delta
	
static func generateZeros(itemsCount):
	var itemArray = []
	for item in range(itemsCount):
		itemArray.append(0)
	return itemArray
	
# zwaraca vektory scian w układzie lokalnym
func getVectorP():
	var vectores = []
	vectores.append( (modelVertex[1] - modelVertex[0]).cross((modelVertex[2] - modelVertex[0])).normalized() )
	vectores.append( (modelVertex[1] - modelVertex[0]).cross((modelVertex[3] - modelVertex[0])).normalized() )
	vectores.append( (modelVertex[2] - modelVertex[1]).cross((modelVertex[3] - modelVertex[1])).normalized() )
	vectores.append( (modelVertex[0] - modelVertex[2]).cross((modelVertex[3] - modelVertex[2])).normalized() )	
	return vectores
	
# zwaraca vektory krawędzi w układzie lokalnym
func getVectorK():
	var vectores = []
	vectores.append((modelVertex[0] - modelVertex[1]).normalized() )
	vectores.append((modelVertex[1] - modelVertex[2]).normalized() )
	vectores.append((modelVertex[2] - modelVertex[0]).normalized() )
	
	vectores.append((modelVertex[3] - modelVertex[0]).normalized() )
	vectores.append((modelVertex[3] - modelVertex[1]).normalized() )
	vectores.append((modelVertex[3] - modelVertex[2]).normalized() ) 
	return vectores
# wykrycie przekrycia

func supportFunc(nodeAVertex, nodeBVertex, os):
	var minA = 1000
	var maxA = -1000
	for nodeA in nodeAVertex:
		var val = nodeA.dot(os)
		if val <= minA:
			minA = val
		if val >= maxA:
			maxA = val
			
	var minB = 1000
	var maxB = -1000
	for nodeB in nodeBVertex:
		var val = nodeB.dot(os)
		if val <= minB:
			minB = val
		if val >= maxB:
			maxB = val

	var valX = true
	if minA < minB:
		valX = maxA < minB
	else:
		valX = maxB < minA
		
	return valX