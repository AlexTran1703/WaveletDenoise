clc; clear all; close all;

[filename, pathname] = uigetfile('*.jpg*');

filewithpath = strcat(pathname, filename);
img = imread(filewithpath);

origin_x = size(img,1);
origin_y = size(img,2);
level = 6;

if origin_x ~= origin_y
    if origin_x > origin_y
            img = imresize(img, [origin_x + 2^level - mod(origin_x, 2^level), origin_x + 2^level - mod(origin_x, 2^level)]);
    else
            img = imresize(img, [origin_y + 2^level - mod(origin_y, 2^level), origin_y + 2^level - mod(origin_y, 2^level)]);
    end
end

%imgnoise = imnoise(img, 'gaussian', 0.1);
imgnoise = imnoise(img, 'speckle', 0.4);

type = 'h';
wavelet_type = 'haar';

%%Decomposition
[LoD,HiD,LoR,HiR] = wfilters(wavelet_type);

[cA1, cH1, cV1, cD1] = dwt2(imgnoise, LoD, HiD); %Level 1
[cA2, cH2, cV2, cD2] = dwt2(cA1, LoD, HiD);      %Level 2
[cA3, cH3, cV3, cD3] = dwt2(cA2, LoD, HiD);      %Level 3
[cA4, cH4, cV4, cD4] = dwt2(cA3, LoD, HiD);      %Level 4
[cA5, cH5, cV5, cD5] = dwt2(cA4, LoD, HiD);      %Level 5


%%Level 5
T_cH5 = sigthresh(cH5, 5, cH5);
T_cV5 = sigthresh(cH5, 5, cV5);
T_cD5 = sigthresh(cH5, 5, cD5);

Y_cH5 = wthresh(cH5, type, T_cH5);
Y_cV5 = wthresh(cV5, type, T_cV5);
Y_cD5 = wthresh(cD5, type, T_cD5);

%%Level 4
T_cH4 = sigthresh(cH4, 4, cH4);
T_cV4 = sigthresh(cH4, 4, cV4);
T_cD4 = sigthresh(cH4, 4, cD4);

Y_cH4 = wthresh(cH4, type, T_cH4);
Y_cV4 = wthresh(cV4, type, T_cV4);
Y_cD4 = wthresh(cD4, type, T_cD4);


%%Level 3
T_cH3 = sigthresh(cH3, 3, cH3);
T_cV3 = sigthresh(cH3, 3, cV3);
T_cD3 = sigthresh(cH3, 3, cD3);

Y_cH3 = wthresh(cH3, type, T_cH3);
Y_cV3 = wthresh(cV3, type, T_cV3);
Y_cD3 = wthresh(cD3, type, T_cD3);

%%Level 2
T_cH2 = sigthresh(cH2, 2, cH2);
T_cV2 = sigthresh(cH2, 2, cV2);
T_cD2 = sigthresh(cH2, 2, cD2);

Y_cH2 = wthresh(cH2, type, T_cH2);
Y_cV2 = wthresh(cV2, type, T_cV2);
Y_cD2 = wthresh(cD2, type, T_cD2);

%%Level 1
T_cH1 = sigthresh(cH1, 1, cH1);
T_cV1 = sigthresh(cH1, 1, cV1);
T_cD1 = sigthresh(cH1, 1, cD1);

Y_cH1 = wthresh(cH1, type, T_cH1);
Y_cV1 = wthresh(cV1, type, T_cV1);
Y_cD1 = wthresh(cD1, type, T_cD1);

%%Reconstruction
Y_cA4 = idwt2(cA5, Y_cH5, Y_cV5, Y_cD5,LoR, HiR);      %Level 1
Y_cA3 = idwt2(Y_cA4, Y_cH4, Y_cV4, Y_cD4,LoR, HiR);    %Level 2
Y_cA2 = idwt2(Y_cA3, Y_cH3, Y_cV3, Y_cD3,LoR, HiR);    %Level 3
Y_cA1 = idwt2(Y_cA2, Y_cH2, Y_cV2, Y_cD2,LoR, HiR);    %Level 4
Y_img = idwt2(Y_cA1, Y_cH1, Y_cV1, Y_cD1,LoR, HiR);    %Level 5


img = imresize(img, [origin_x, origin_y]);
imgnoise = imresize(imgnoise, [origin_x, origin_y]);
Y_img = imresize(uint8(Y_img), [origin_x, origin_y]);

error = abs(img - Y_img);
decibels = 20*log10(1/(sqrt(mean(mean(error.^2)))));

disp('Error in dB');
fprintf('R = %f\nB = %f\nG = %f\n',decibels(:,:,1), decibels(:,:,2), decibels(:,:,3) );

[peak_y,snr_y] = psnr(Y_img,img);
[peak_noise,snr_noise] = psnr(imgnoise,img);

disp('PeakSNR and SNR of denoise image');
fprintf('Peak_SNR = %f\n SNR = %f\n', peak_y, snr_y);

if origin_x > origin_y
    subplot(131); imshow(img, 'InitialMagnification', 'fit'); title('Original image');
    subplot(132); imshow(imgnoise, 'InitialMagnification', 'fit'); title('Noise image');
    subplot(133); imshow(Y_img, 'InitialMagnification', 'fit'); title('Denoised image');
else
    subplot(221); imshow(img, 'InitialMagnification', 'fit'); title('Original image');
    subplot(222); imshow(imgnoise, 'InitialMagnification', 'fit'); title('Noise image');
    subplot(223); imshow(Y_img, 'InitialMagnification', 'fit'); title('Denoised image');
end
