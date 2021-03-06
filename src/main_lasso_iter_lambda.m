close all;
clear all;

ltfatstart;

%load signal
[s,Fs]  = audioread('piano.wav');
% s=s(1:220);

T = length(s);
Time = linspace(0,T/Fs,T);

figure;
plot(Time, s);
title('Observed signal');

%induce noise
snrlevel = 10;
sn = awgn(s,snrlevel,'measured');
disp(snr(s,sn-s));

sigma_noise = norm(s)^2*10^(-snrlevel/10)/T;

noise = sqrt(sigma_noise)*randn(size(s));
sn = s + noise;
disp(snr(s,sn-s));
snrorg = snr(s,sn-s);

% Gabor parameters: window length, type, overlap
M = 1024;
a = M/2;
g = gabwin({'tight', 'hann'}, a, M);

% Gabor transform
G_sn = dgtreal(sn, g, a, M);
figure;
plotdgtreal(G_sn,a,M,Fs);
title('Gabor coefficients of noisy signal');

i=1;
snr_array = [];
l = logspace(-3,-1);
while(i<=50) 
% lambda = sqrt(sigma_noise); %%%%%%vary lambda here!
lambda = l(i)
G_sd = G_sn.*max(0,1-lambda./abs(G_sn));

% WG Lasso

%size of the neighborhood
K = 5; 
neigh = ones(1,K);
neigh = neigh/norm(neigh(:),1);

% center of the window
c = ceil(K/2);

% matrix to stock the local energy of each neighborhood
% centralize gabor squared coefficients, mirror left and right borders

[MG,NG] = size(G_sn);
W = zeros(MG, NG+K-1);
W(:, c: NG+c-1) = abs(G_sd).^2;
W(:, 1:c-1) =  fliplr(W(:, c : 2*(c-1))); % left border
W(:, NG+c:end) = fliplr(W(:, NG - K +2*c: NG+c-1));% right border

% neighborhood energy
W = (conv2(W, neigh, 'same'));
W = W(:, c : NG + c -1);

% thresholding
W = sqrt(W);
G_sd = G_sn.*max(0,1-(lambda./W));

figure;
plotdgtreal(G_sd,a,M,Fs);
title('Gabor coeff. after WGLASSO thresholding');
hold on

% snr
sd = idgtreal(G_sd,g,a,M,T);
disp(snr(s,sd-s));
snrlasso = snr(s,sd-s);
snr_array = [snr_array snrlasso];

% i = i*10;
% i = i + 0.1;
i=i+1;

end

figure; plot(l,snr_array); 
title('Variation of SNR with hyperparameter lambda')
xlabel('lambda') % x-axis label
ylabel('SNR (in dB)') % y-axis label

% Iterative thresholding
% 
% nbit = 30; %number of iteration for ISTA
% nb_xp = 30; % number of values for the parameter
% lambda_values_it = logspace(-3/4,-2,nb_xp);%generate the vector of parameter
% 
% snr_soft_it = zeros(nb_xp,1);
% sigma_soft_it = zeros(nb_xp,1);
% 
% % inititalise algo with 0
% G_sd = 0.*G_sn;
% k=0;
% 
% % ISTA for various lambda
% for lambda= l  %lambda_values_it . %%
%     k = k+1; % XP number k
%     for it=1:nbit % ISTA loop
%         r = sn-idgtreal(G_sd,g,a,M,T);
%         G_sd = G_sd + dgtreal(r, g, a, M); % Gradient step
%         G_sd = G_sd.*max(0,1-lambda./abs(G_sd)); % Thresholding step
%     end
%     sd_soft = idgtreal(G_sd,g,a,M,T); %  time domain
%     sigma_soft_it(k) = var(sn-sd_soft); %  variance of the residual
%     snr_soft_it(k) = snr(s,sd_soft); %  output SNR
% end
% 
% 
% figure;
% hold on
% plot(lambda_values_it,snr_soft_it,'b');
% [~,k_soft] = min(abs(sigma_soft_it-sigma_noise));
% plot(lambda_values_it(k_soft),snr_soft_it(k_soft),'+b');
% % set_graphic_sizes([], 20,2);
% % set_label('\lambda', 'SNR');
% % title('SNR vs \lambda (L1 minimization)')
% hold off


audiowrite('_1.original.wav',s,Fs);
audiowrite('_2.noisy.wav',sn,Fs);
audiowrite('_3.rec_sd.wav',sd,Fs);
% audiowrite('_4.rec_sd_soft.wav',sd_soft,Fs);
