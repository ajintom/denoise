ltfatstart;

%load signal
[s,Fs]  = audioread('piano.wav');
s=s(1:220);

T = length(s);
Time = linspace(0,T/Fs,T);

figure;
plot(Time, s);
title('Observed signal');

%induce noise
snrlevel = 10;
% sn = awgn(s,snrlevel,'measured');
% disp(snr(s,sn));

sigma_noise = norm(s)^2*10^(-snrlevel/10)/T; %??????????????
noise = sqrt(sigma_noise)*randn(size(s));
sn = s + noise;
disp(snr(s,sn));

%  gabors parameters for transient (short Hann window with 50% overlap)
M1 = 64;
a1 = M1/2;
g1 = gabwin({'tight', 'hann'}, a1, M1);
G_sn1 = dgtreal(sn, g1, a1, M1);

% tonal (long Hann window with 50% overlap)
M2 = 4096;
a2 = M2/2;
g2 = gabwin({'tight', 'hann'}, a2, M2);
G_sn2 = dgtreal(sn, g2, a2, M2);

% setting number of iteration for ISTA and the number of lambda parameter
nbit = 30;
nb_xp = 30;
lambda_values_double = logspace(-3/4,-2,nb_xp);

% ton+trans+noise hybrid decomposition with ISTA and Soft thresholding

snr_soft_double = zeros(nb_xp,1);
sigma_soft_double = zeros(nb_xp,1);


G_sd1 = 0.*G_sn1;
G_sd2 = 0.*G_sn2;

k=0;
for lambda=lambda_values_double
    k = k+1;
    for it=1:nbit
        G_sd_old1 = G_sd1;
        G_sd_old2 = G_sd2;

        r = sn-idgtreal(G_sd1,g1,a1,M1,T)-idgtreal(G_sd2,g2,a2,M2,T);
        G_sd1 = G_sd1 + dgtreal(r, g1, a1, M1)/2;
        G_sd2 = G_sd2 + dgtreal(r, g2, a2, M2)/2;

        G_sd1 = G_sd1.*max(0,1-(lambda/2)./abs(G_sd1));
        G_sd2 = G_sd2.*max(0,1-(lambda/2)./abs(G_sd2));
    end
    sd_trans = idgtreal(G_sd1,g1,a1,M1,T);
    sd_ton = idgtreal(G_sd2,g2,a2,M2,T);
    sd_soft =  sd_trans + sd_ton;

    sigma_soft_double(k) = var(sn-sd_soft);
    snr_soft_double(k) = snr(s,sd_soft);
end


figure;
hold on
plot(lambda_values_double,snr_soft_double,'b');
[~,k_soft] = min(abs(sigma_soft_double-sigma_noise));
plot(lambda_values_double(k_soft),snr_soft_double(k_soft),'+b');
hold off

