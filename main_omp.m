
[y, fs]=audioread('sine400.wav');
y = y(1:fs);

figure;
plot(y);


mpdict = wmpdictionary(length(y),'lstcpt',{'sin'});
omp_sig = my_omp(2,mpdict,y);

figure;
my_omp_sig = mpdict * omp_sig;
plot(my_omp_sig);

yn = awgn(y,10,'measured');

[yfit,r,coeff,iopt,qual] = wmpalg('OMP',yn,mpdict,'typeplot','movie','stepplot',1, 'itermax',2,'maxerr',{'L1',33});

audiowrite('1.original.wav',y,fs);
audiowrite('2.noisy.wav',yn,fs);
audiowrite('3.my_omp.wav',my_omp_sig,fs);
audiowrite('4.rec.wav',yfit,fs);