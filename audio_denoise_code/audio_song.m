%matlab program to denoise using wden
clc; clear all; close all
[filename,pathname] = uigetfile('*.*','select input audio');
%Select your own path for wav file
[x,Fs]=audioread('E:\matlab\R2019b\bin\project_dsp\instrument.wav');

%adding white gaussian noise
% awgn(signal, signal to noise ratio,'measured');
xn = awgn(x,15,'measured');

% Perform a 3-level wavelet decomposition using the 'sym8' wavelet
[c,l] = wavedec(x,3,'sym8');

% Extract the approximation coefficients and all three detail coefficients
% (corresponding to levels 1, 2, and 3)
a3 = appcoef(c,l,'sym8',3); % Approximation coefficients at level 3
d3 = detcoef(c,l,3); % Detail coefficients at level 3
d2 = detcoef(c,l,2); % Detail coefficients at level 2
d1 = detcoef(c,l,1); % Detail coefficients at level 1
n1 = numel(d1); n2 = numel(d2); n3 = numel(d3); ap3 = numel(a3);
N = length(x); % sample lenth
fprintf("size of original signal:");
disp(N);
fprintf("number of detail coefficients generated after 1 level:");
disp(n1);
fprintf("number of detail coefficients generated after 2 levels:");
disp(n2);
fprintf("number of detail coefficients generated after 3 levels:");
disp(n3);
fprintf("number of approximation coefficients generated after 3 level:");
disp(ap3);
figure
% Plot the approximation and detail coefficients
subplot(4,1,1); plot(a3); title('Approximation coefficients A3');
subplot(4,1,2); plot(d3); title('Detail coefficients D3');
subplot(4,1,3); plot(d2); title('Detail coefficients D2');
subplot(4,1,4); plot(d1); title('Detail coefficients D1');

%XD = wden(X,TPTR,SORH,SCAL,N,wname)
wname ='sym8';
xden = wden(xn,'sqtwolog','s','mln',3,wname);
% signal to noise ratio
snr_vals = snr(x,x-xden)

%Mean square error
mse_vals = immse(x, xden)

sdr_vals = 10*log10(norm(x)^2 / norm(x - xden)^2)
% The PSNR value measures the ratio of the peak signal-to-noise 
PS_NR = psnr(x,xden)

% 2nd method
xden2 = wden(xn,'rigrsure','s','mln',3,wname);

snr_vals2 = snr(x,x-xden2)
mse_vals2 = immse(x, xden2)
sdr_vals2 = 10*log10(norm(x)^2 / norm(x - xden2)^2)
PS_NR2 = psnr(x,xden2)

figure
subplot(221)
plot(x);
title('original signal');
subplot(222)
plot(xn,'r');
title('Noisy signal');
subplot(223)
plot(xden,'g');
title('Denoised signal');
subplot(224)
plot(xden2,'r');
title('Denoised signal2');
audiowrite('method1.wav',xden,44100)
audiowrite('method2.wav',xden2,44100);


