

clc; clear all; close all

% Piece of code to Play Audio file
recObj=audiorecorder(8000,8,1,-1);%audiorecorder object with 
                                 %samplerate,nbits,Number of channels & Device ID 
disp('start speaking.')         %waiting time to start speaking
recordblocking(recObj,5);       %Recording voice for 5 seconds
disp('End of recording.');      % To stop end of recording
play(recObj);                   %command to play recorder object
% Save recorded data to a temporary file
tempFile = 'temp.wav';
audiowrite(tempFile, getaudiodata(recObj), recObj.SampleRate);

% Read the temporary file and get sample rate
[x, Fs] = audioread(tempFile);
delete(tempFile); % Remove the temporary file

% Add white Gaussian noise with SNR of 15 dB
xn = awgn(x, 15, 'measured');

% Denoise the noisy signal using wavelet-based denoising
% Using soft thresholding (s) and symlet 8 (sym8) wavelet 
% with level-dependent denoising level of 3 (mln)
wname = 'sym8';
xden = wden(xn, 'sqtwolog', 's', 'mln', 3, wname);


% signal to noise ratio
%In this case, the 'snr' function takes two arguments: 
%the original image 'x', and the noise signal, 
%which is the difference between 'x' and 'xden'.
snr_vals = snr(x,x-xden)
%Mean square error
%The MSE provides an estimate of signal quality, meaning that 
%the lower the MSE, the better the quality of the signal. 
mse_vals = immse(x, xden)
%mse_db = 10*log10(mse_vals)
sdr_vals = 10*log10(norm(x)^2 / norm(x - xden)^2)
% The PSNR value measures the ratio of the peak signal-to-noise 
%level in decibels (dB) between the original and denoised images,
%higher the PSNR value, the lower the amount of distortion between
%the original and the processed images.
PS_NR = psnr(x,xden)

% 2nd method
xden2 = wden(xn,'rigrsure','s','mln',3,wname);

snr_vals2 = snr(x,x-xden2)
mse_vals2 = immse(x, xden2)
%mse_db2 = 10*log10(mse_vals)
sdr_vals2 = 10*log10(norm(x)^2 / norm(x - xden2)^2)
PS_NR2 = psnr(x,xden2)

% Play audio signals
% player1= audioplayer(x, recObj.SampleRate)   % Original audio signal
% player2=audioplayer(xn, recObj.SampleRate) % Original audio signal with noise added
% player3=audioplayer(xden, recObj.SampleRate) % Denoised audio signal
% player4=audioplayer(xden2, recObj.SampleRate) % Denoised audio signal
% 
% play(player1);
% play(player2);
% play(player3);
% play(player4);
%Create audioplayer objects and store them in a cell array
players = cell(1,4);
players{1} = audioplayer(x, recObj.SampleRate);   % Original audio signal
players{2} = audioplayer(xn, recObj.SampleRate); % Original audio signal with noise added
players{3} = audioplayer(xden, recObj.SampleRate); % Denoised audio signal
players{4} = audioplayer(xden2, recObj.SampleRate); % Denoised audio signal

%Play audio signals sequentially
for ii = 1:4
    playblocking(players{ii});
end



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





