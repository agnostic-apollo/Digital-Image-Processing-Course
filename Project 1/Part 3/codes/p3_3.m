%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q3.pdf

%add uncorrelated gaussian noise to input image and recover input image after applying median filter


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])


%read input image as image
imageName = 'cameraman.tif';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg

image = mat2gray(image); %rescale to 0-1

imageStdDev = Functions.standtardDeviationOfImage(image);

subplot(3,2,1), imshow(image), title([imageName, ' Grayscale Image']);  %show input image grayscale in subplot 
subplot(3,2,2), hist(image(:),256), title({[imageName, ' Histogram'];['(std = ', num2str(imageStdDev), ')']}); %show input image histogram and std dev in subplot

[M,N] = size(image);

%create normally distributed noise1 equal to input image dimensions with standard deviation 0.2 and mean 10
noise1 = Functions.createNoiseImage(M,N,0.2,10);
noise1 = mat2gray(noise1); %rescale to 0-1

%add noise1 to input image and rescale to 0-1
imageWithNoise1 = mat2gray(image + noise1);

imageWithNoise1StdDev = Functions.standtardDeviationOfImage(imageWithNoise1);

subplot(3,2,3), imshow(imageWithNoise1), title([imageName, ' with Noise1']); %show input image with noise1 in subplot 
subplot(3,2,4), hist(imageWithNoise1(:),256), title({[imageName, ' with Noise1 Histogram'];['(std = ', num2str(imageWithNoise1StdDev), ')']}); %show input image with noise1 histogram and std dev in subplot

%apply median filter to noisy image
%imageWithNoiseAfterMedianFilter = medfilt2(imageWithNoise1); % matlab default
imageWithNoise1AfterMedianFilter = Functions.medianFilter(imageWithNoise1);

imageWithNoise1AfterMedianFilter1StdDev = Functions.standtardDeviationOfImage(imageWithNoise1AfterMedianFilter);

subplot(3,2,5), imshow(imageWithNoise1AfterMedianFilter), title([imageName, ' with Noise1 after Median Filter']); %show input image with noise1 after median filter in subplot 
subplot(3,2,6), hist(imageWithNoise1AfterMedianFilter(:),256), title({[imageName, ' with Noise1 After Median Filter Histogram'];['(std = ', num2str(imageWithNoise1AfterMedianFilter1StdDev), ')']}); %show input image with noise1 after median filter histogram and std dev in subplot

