extends MeshInstance

export var use_quaternions = false
 
var mass = 1.0
var mu   = 1.0/mass
var Principal_Moments_of_Inertia     = Vector3(2*mass/3.0,2*mass/3.0,2*mass/3.0) # 1/12 * m * (2^2 + 2^2) = 8/12 m = 2/3 m
var inv_Principal_Moments_of_Inertia = Vector3(1.0,1.0,1.0) / Principal_Moments_of_Inertia
 
var XYZ = [Vector3(1.0,0.0,0.0),
           Vector3(0.0,1.0,0.0),
           Vector3(0.0,0.0,1.0)] # wersory lokalnego układu odniesienia
 
# zmienne do symulacji ruchu postępowego
var prev_position   = Vector3(0.0,0.0,0.0)
var position        = Vector3(0.0,0.0,0.0)
var next_position   = Vector3(0.0,0.0,0.0)
export var velocity = Vector3(0.0,0.0,0.0)
var next_velocity   = Vector3(0.0,0.0,0.0)
 
# zmienne do symulacji ruchu obrotowego
export var angular_velocity      = Vector3(1.0,0.0,0.0)
var next_angular_velocity        = Vector3(0,0,0)
var rotation_representation      = Quat(Vector3(0.6,0.8,0.0),0.123)
var next_rotation_representation = Quat(0,0,0,1)
 
# misc
var time = 10.0
var arrow = load("arrow.tscn")
var arrow_clrs = [Color(0.8,0.0,0.0),
                  Color(0.0,0.8,0.0),
                  Color(0.0,0.0,0.8)]
var isStatic = false
 
func _ready():
	# tworzenie strzałek
	for i in range(3):
		var j = i+1 if i<2 else 0
		var v = arrow.instance()
		v.set_color(arrow_clrs[i])
		v.rotate(XYZ[j],0.5*PI)
		add_child(v)
 
	# inicjowanie początkowej trasformacji
	for i in range(3):
		XYZ[i] = self.get_transform().basis.xform(XYZ[i])
	position = translation
	prev_position = position - velocity*get_physics_process_delta_time()
 
	if use_quaternions:
		self.transform = trans_from_quat(rotation_representation)
 
 
func _physics_process(delta):
	if !isStatic:
		verlet(delta) # wykonaj całkowanie
		accept(delta) # zakceptuj nowe zmienne
 
func _process(delta):
	if time > 3:
		time = 0.0
	time += delta
 
	if use_quaternions:
		#print(rotation_representation.length())
		transform = trans_from_quat(rotation_representation)
	else:
		# proteza
		self.rotate(angular_velocity.normalized(),angular_velocity.length()*delta)
	translation = position
 
 
# zwracanie lokalnego ukłądu odniesienia
func get_local_direction(x):
	match x:
		0, "x", "X", "i":
			return self.get_transform().basis.xform(XYZ[0])
		1, "y", "Y", "j":
			return self.get_transform().basis.xform(XYZ[1])
		2, "z", "Z", "k":
			return self.get_transform().basis.xform(XYZ[2])
	return -1
 
# algorytm verleta
func verlet(delta, F = force(delta), M = torque(delta)):
	next_position = 2*position - prev_position + mu*F*pow(delta,2)
	next_velocity = (next_position - position)/delta
	next_angular_velocity = angular_velocity + delta*inv_Principal_Moments_of_Inertia*(M - angular_velocity.cross(Principal_Moments_of_Inertia*angular_velocity))
	#TODO: Całkowanie równań ruchu dla kwaternionu
	next_rotation_representation = rotation_representation +  ((quaternionize(next_angular_velocity) * rotation_representation) / 2.0) * delta
 
# zmod. algorytm eulera
func euler(delta, F = force(delta), M = torque(delta)):
	next_velocity = velocity + delta*mu*F
	next_position = position + delta*next_velocity
	next_angular_velocity = angular_velocity + delta*inv_Principal_Moments_of_Inertia*(M - angular_velocity.cross(Principal_Moments_of_Inertia*angular_velocity))
	#TODO: Całkowanie równań ruchu dla kwaternionu
	next_rotation_representation = rotation_representation +  ((quaternionize(next_angular_velocity) * rotation_representation) / 2.0) * delta
 
 
# akceptacja ruchu
func accept(delta):
	prev_position = position
	position = next_position
	velocity = next_velocity
	angular_velocity = next_angular_velocity
	rotation_representation = next_rotation_representation
 
 
# moment siły
func torque(delta):
	return Vector3(0.0,0.0,0.0)#-0.1*angular_velocity
 
# siła
func force(delta):
	return -0.1*position-0.1*velocity # naiwna siła sprężystości
 
# wektor w kwaternion
func quaternionize(vec):
	return Quat(vec.x,vec.y,vec.z,0)
 
# kwaternion w wektor
func dequaternionize(quat):
	return Vector3(quat.x,quat.y,quat.z)
 
# kwaternion w transformację
func trans_from_quat(Q):
	var i = Vector3(1, 0, 0) + Vector3(-2*(pow(Q.y,2) + pow(Q.z,2)), 2*(Q.x*Q.y + Q.z*Q.w), 2*(Q.x*Q.z - Q.y*Q.w)) / Q.length_squared ()
	var j = Vector3(0, 1, 0) + Vector3(2*(Q.x*Q.y - Q.z*Q.w), -2*(pow(Q.z,2) + pow(Q.x,2)), 2*(Q.y*Q.z + Q.x*Q.w)) / Q.length_squared ()
	var k = Vector3(0, 0, 1) + Vector3(2*(Q.x*Q.z + Q.y*Q.w), 2*(Q.y*Q.z - Q.x*Q.w), -2*(pow(Q.x,2) + pow(Q.y,2))) / Q.length_squared ()
	return Transform(i,j,k,Vector3(0,0,0))