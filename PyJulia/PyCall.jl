using Pkg
Pkg.add("PyCall")  # Solo la primera vez

using PyCall

# Importar el módulo math de Python
math = pyimport("math")

# Usar la función sqrt de Python desde Julia
raiz = math.sqrt(16)
println("La raíz cuadrada de 16 calculada con Python desde Julia es: $raiz")
