% Desde Octave
system('julia integra_trapecio.ij > resultado_julia.txt');
resultado = dlmread('resultado_julia.txt');
disp(["Resultado de Julia: ", num2str(resultado)]);
