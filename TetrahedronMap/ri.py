lines = []
with open('dane.txt') as f:
    lines = f.read().splitlines()
w = [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]

for i in range(1, len(lines)):
    words = lines[i].split()
    x = float(words[0])
    y = float(words[1])
    z = float(words[2])
    m = float(words[3])

    w[0][0] += m * (y*y + z*z)
    w[1][1] += m * (z*z + x*x)
    w[2][2] += m * (x*x + y*y)
    w[0][1] -= m * x * y
    w[0][2] -= m * z * x
    w[1][2] -= m * y * z
    
w[1][0] = w[0][1]
w[2][0] = w[0][2]
w[2][1] = w[1][2]
# print(w[0])
# print(w[1])
# print(w[2])

for wAr in w:
    for w in wAr:
        print("{0:.3f} ".format(w), end='')
    print(" ")

    

    
