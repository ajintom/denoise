ltfatstart;

%load signal
[s,Fs]  = audioread('sine400.wav');
s=s(1:220);

T = length(s);
Time = linspace(0,T/Fs,T);

figure;
plot(Time, s);
title('Observed signal');

%induce noise
snrlevel = 10;
sn = awgn(s,snrlevel,'measured');
disp(snr(s,xn));

sigma_noise = norm(s)^2*10^(-snrlevel/10)/T; %??????????????
% noise = sqrt(sigma_noise)*randn(size(s));
% xn = s + noise;
% disp(snr(s,sn));

% Gabor parameters: window length, type, overlap
M = 1024;
a = M/2;
g = gabwin({'tight', 'hann'}, a, M);

% Gabor transform
G_sn = dgtreal(sn, g, a, M);
figure;
plotdgtreal(G_sn,a,M,Fs);
title('Gabor coefficients of noisy signal');

% soft-threshold
lambda = sqrt(sigma_noise);
G_sd = G_sn.*max(0,1-lambda./abs(G_sn));
figure;
plotdgtreal(G_sd,a,M,Fs);
title('Gabor coefficients after Soft-Thresholding');

% snr calc
xd = idgtreal(G_sd,g,a,M,T);
disp(snr(s,sd));
