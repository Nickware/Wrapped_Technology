% Leer valores finales
data = dlmread('valores_finales.csv', ',');
ST = data(:, 2);

figure;
hist(ST, 50);
xlabel('S_T (moneda local por USD)');
ylabel('Frecuencia');
title('Distribución de S_T al final del horizonte');

% Estadísticas
mean_ST = mean(ST);
std_ST = std(ST);
p5 = prctile(ST, 5);
p95 = prctile(ST, 95);

disp(['E[S_T] = ', num2str(mean_ST)]);
disp(['SD[S_T] = ', num2str(std_ST)]);
disp(['5%  = ', num2str(p5)]);
disp(['95% = ', num2str(p95)]);
