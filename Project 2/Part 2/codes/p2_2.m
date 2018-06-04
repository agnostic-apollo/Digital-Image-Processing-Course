%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in section 4 of Gamma.pdf and Proj2_Q2.pdf

%gamma correct the input image


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])


%read input image as image
imageName = 'linear.tif';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
grayImage = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg


subplot(1,2,1), imshow(grayImage), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot


gamma = 2.19; %set gamma value for correction
gammaCorrectedImage = Functions.gammaCorrectImage(grayImage, gamma); %gamma correct the image


subplot(1,2,2), imshow(gammaCorrectedImage), title([imageName, ' After Gamma Correction of ', num2str(gamma)]); %show input image after gamma correction in subplot



