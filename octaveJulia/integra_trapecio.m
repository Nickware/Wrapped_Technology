% Integra la función f(x) = sqrt(1 + cos^2(x)) en el intervalo [0, 50] usando el método del trapecio con n = 1000 subintervalos.
% La función debe imprimir el resultado con 6 decimales.
% Para ejecutar esta función, simplemente llama a integra_trapecio() en la consola de Octave.
% Ejemplo de uso:
% >> resultado = integra_trapecio();
% El resultado se imprimirá en la consola con 6 decimales.
% Nota: Asegúrate de tener Octave instalado y configurado correctamente para ejecutar esta función.
% La función utiliza el método del trapecio para aproximar la integral de la función dada en el intervalo especificado.
% La función f(x) se define como sqrt(1 + cos^2(x)), y el intervalo de integración es de 0 a 50 con 1000 subintervalos para una mayor precisión.
% La función calcula el valor de la integral y lo imprime en la consola con el formato requerido.
% La función devuelve el resultado de la integral, aunque el resultado también se imprime en la consola.
% Asegúrate de ejecutar esta función en un entorno compatible con Octave para obtener el resultado correcto.
% La función utiliza la función linspace para generar los puntos de evaluación y arrayfun para aplicar la función f a cada uno de esos puntos, sumando los resultados según el método del trapecio.
% La función también utiliza printf para formatear la salida del resultado con 6 decimales, asegurando que se cumpla el requisito de formato especificado.
% La función integra_trapecio es una implementación directa del método del trapecio para calcular la integral de la función dada en el intervalo especificado, y se espera que el resultado sea una aproximación precisa de la integral real debido al número de subintervalos utilizados.
function resultado = integra_trapecio()
  f = @(x) sqrt(1 + cos(x)^2);
  a = 0; b = 50; n = 1000;
  x = linspace(a, b, n+1);
  h = (b-a)/n;
  s = f(a) + f(b) + 2*sum(arrayfun(f, x(2:end-1)));
  resultado = h/2 * s;
  printf('%.6f\n', resultado); % SOLO la línea con el resultado
end
