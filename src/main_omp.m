close all;
clear all;

load cuspamax;

[y, fs]=audioread('sine400.wav');
%y = y(1:10:132000);
y = y(1:fs);
% 
% y = cuspamax';
% y = y - y(1); 
% y = y/max(abs(y(:)));

iter = 20;
err = 40;  %40 for sine, change dict also, else 13

%induce noise
snrlevel = 15;
yn = awgn(y,snrlevel,'measured');
disp(snr(y,yn-y));
snr_org_omp = snr(y,yn-y);
figure;
plot(yn);
title('Signal with AWGN')

mpdict = wmpdictionary(length(y),'lstcpt',{'sin'}); %dct or sin

for i = 1 : size(mpdict,2)
        mpdict(:,i) = mpdict(:,i) / norm(mpdict(:,i));
end
[omp_sig,iter_done] = my_omp(iter,mpdict,yn,y,err/100);
my_omp_sig = mpdict * omp_sig;

figure;
plot(my_omp_sig);
title('Reconstructed denoised signal from my-omp')


[yfit,r,coeff,iopt,qual] = wmpalg('OMP',yn,mpdict,'typeplot','movie','stepplot',1, 'itermax',iter,'maxerr',{'L1',err});

audiowrite('1.original.wav',y,fs);
audiowrite('2.noisy.wav',yn,fs);
audiowrite('3.my_omp.wav',my_omp_sig,fs);
audiowrite('4.rec.wav',yfit,fs);