import time
import math

start = time.time()
x,y,z = 1.0, 2.0, 3.0
for j in range(3000):
    for i in range(1000000):
        r = math.sqrt(x**2 + y**2 + z**2)
end = time.time()
print("Python time =", end - start, "seconds")