close all;
clear all;

[y, fs]=audioread('sine400.wav');
y = y(1:220);

iter = 40;
noise = 9;
yn = awgn(y,noise,'measured');
figure;
plot(yn);

mpdict = wmpdictionary(length(y),'lstcpt',{'sin'});

for i = 1 : size(mpdict,2)
        mpdict(:,i) = mpdict(:,i) / norm(mpdict(:,i));
end
omp_sig = my_omp(iter,mpdict,yn);
figure;
my_omp_sig = mpdict * omp_sig;

plot(my_omp_sig);

[yfit,r,coeff,iopt,qual] = wmpalg('OMP',yn,mpdict,'typeplot','movie','stepplot',1, 'itermax',iter,'maxerr',{'L1',33});

audiowrite('1.original.wav',y,fs);
audiowrite('2.noisy.wav',yn,fs);
audiowrite('3.my_omp.wav',my_omp_sig,fs);
audiowrite('4.rec.wav',yfit,fs);