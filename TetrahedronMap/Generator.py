import csv
import numpy


def getVertex():
    vertex = []
    with open('czworokontCSV.csv', 'rt') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            col = row[0].split(';')
            vertex.append(numpy.array([float(col[0]), float(col[1]), float(col[2])]))
    return vertex

def dFrom( point0, point1, point2 ):
    v1 = point1 - point0
    v2 = point2 - point0
    n = numpy.cross(v1, v2)
    nMin = -1 * n
    alfa = numpy.dot((nMin), point0)
    d = (numpy.dot(n, point) + alfa) / numpy.linalg.norm(n)
    return d

def isInMesh(point, meshPoint):
    d1 = dFrom(meshPoint[0], meshPoint[1], meshPoint[2])
    d2 = dFrom(meshPoint[0], meshPoint[2], meshPoint[3])
    d3 = dFrom(meshPoint[2], meshPoint[1], meshPoint[3])
    d4 = dFrom(meshPoint[1], meshPoint[0], meshPoint[3])
    return d1 < 0 and d2 < 0 and d3 < 0 and d4 < 0

if __name__ == "__main__":
    vertex = getVertex()
    n = 0.1
    mass = 5.0

    pointInsiteMesh = []
    for x in numpy.arange(-2, 2, n):
        for y in numpy.arange(-2, 2, n):
            for z in numpy.arange(-2, 2, n):
                point = numpy.array([x, y, z])
                if isInMesh(point, vertex):
                    pointInsiteMesh.append(point)

    massPart = mass / len(pointInsiteMesh)

    f = open('dane.txt', 'w')

    f.writelines("x y z m" + '\n')

    for point in pointInsiteMesh:
        line = "" + "{0:.2f}".format(point[0]) + " " + "{0:.2f}".format(point[1]) + " " + "{0:.2f}".format(point[2])+ " " + "{0:.4f}".format(massPart) + '\n'
        f.writelines(line)

    f.close()

