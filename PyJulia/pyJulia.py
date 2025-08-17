from julia import Main

# Definir función en Julia desde Python
Main.eval("""
function doble(x)
    return 2x
end
""")

# Invocar la función Julia desde Python
resultado = Main.doble(10)
print("El doble de 10 calculado con Julia desde Python es:", resultado)
