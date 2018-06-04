%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q3.pdf

%create two noisy images after adding two different uncorrelated gaussian noise to input image
%average both noisy images and see if the averaged images are closer to input image


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

subplot(3,2,1), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot
subplot(3,2,2), hist(image(:),256), title({[imageName, ' Histogram'];['(std = ', num2str(imageStdDev), ')']}); %show input image histogram and std dev in subplot

[M,N] = size(image);

%create normally distributed noise1 equal to input image dimensions with standard deviation 0.2 and mean 0
noise1 = Functions.createNoiseImage(M,N,0.2,0);
noise1 = mat2gray(noise1); %rescale to 0-1

noise1StdDev = Functions.standtardDeviationOfImage(noise1);

subplot(3,2,3), imshow(noise1), title('Noise1 Image'); %show noise1 image in subplot
subplot(3,2,4), hist(noise1(:),256), title({'Noise1 Image Histogram';['(std = ', num2str(noise1StdDev), ')']}); %show noise1 image histogram and std dev in subplot


%create normally distributed noise2 equal to input image dimensions with standard deviation 0.2 and mean 0
noise2 = Functions.createNoiseImage(M,N,0.2,0);
noise2 = mat2gray(noise2); %rescale to 0-1

noise2StdDev = Functions.standtardDeviationOfImage(noise2);

subplot(3,2,5), imshow(noise2), title('Noise2 Image'); %show noise2 image in subplot
subplot(3,2,6), hist(noise2(:),256), title({'Noise2 Image Histogram';['(std = ', num2str(noise2StdDev), ')']}); %show noise2 image histogram and std dev in subplot



figure('units','normalized','outerposition',[0 0 1 1])

%add noise1 to input image and rescale to 0-1
imageWithNoise1 = mat2gray(image + noise1);

imageWithNoise1StdDev = Functions.standtardDeviationOfImage(imageWithNoise1);

subplot(3,2,1), imshow(imageWithNoise1), title([imageName, ' with Noise1']); %show input image with noise1 in subplot
subplot(3,2,2), hist(imageWithNoise1(:),256), title({[imageName, ' with Noise1 Histogram'];['(std = ', num2str(imageWithNoise1StdDev), ')']}); %show input image with noise1 histogram and std dev in subplot


%add noise2 to input image and rescale to 0-1
imageWithNoise2 = mat2gray(image + noise2);

imageWithNoise2StdDev = Functions.standtardDeviationOfImage(imageWithNoise2);

subplot(3,2,3), imshow(imageWithNoise2), title([imageName, ' with Noise2']); %show input image with noise2 in subplot
subplot(3,2,4), hist(imageWithNoise2(:),256), title({[imageName, ' with Noise2 Histogram'];['(std = ', num2str(imageWithNoise2StdDev), ')']}); %show input image with noise2 histogram and std dev in subplot

%average both noisy images
avgOfNoisyImages = (imageWithNoise1 + imageWithNoise2)/2;

%{
%avg N noise images
avgOfNoisyImages = imageWithNoise1;
 for z=1:20
   avgOfNoisyImages = (avgOfNoisyImages + mat2gray((image + mat2gray(Functions.createNoiseImage(M,N,0.2,0)))) )/2;
 end
 %}  

avgOfNoisyImagesStdDev = Functions.standtardDeviationOfImage(avgOfNoisyImages);

subplot(3,2,5), imshow(avgOfNoisyImages), title('Average of Noisy images'); %show input image with noise1 and noise2 in subplot
subplot(3,2,6), hist(avgOfNoisyImages(:),256), title({'Average of Noisy images Histogram';['(std = ', num2str(avgOfNoisyImagesStdDev), ')']}); %show input image with noise1 and noise2 histogram and std dev in subplot


