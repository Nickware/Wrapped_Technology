function resultado = integra_trapecio()
  f = @(x) sqrt(1 + cos(x)^2);
  a = 0; b = 50; n = 1000;
  x = linspace(a, b, n+1);
  h = (b-a)/n;
  s = f(a) + f(b) + 2*sum(arrayfun(f, x(2:end-1)));
  resultado = h/2 * s;
  printf('%.6f\n', resultado); % SOLO la línea con el resultado
end
