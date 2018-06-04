%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q2.pdf

%read image and contrast strech and histogram equalize it


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])


%read input image as image
imageName = 'MyBadHist.jpg';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end

image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg

subplot(3,2,1), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale  in subplot
subplot(3,2,2), hist(image(:),0:255), title([imageName, ' Histogram']); %show input image histogram in subplot

%contrast stretch the input image with 1% saturation
lowerSaturationLimit = 0.01;
higherSaturationLimit = 0.99;
contrastStretchedImage = Functions.contrastStretchImage(image,lowerSaturationLimit,higherSaturationLimit);

subplot(3,2,3), imshow(contrastStretchedImage), title([imageName, ' After Contrast Stretching']); %show contrast stretched input image in subplot
subplot(3,2,4), hist(contrastStretchedImage(:),0:255), title([imageName, ' Histogram After Contrast Stretching']); %show contrast stretched input image histogram in subplot


%histogram equalize the input image
histogramEqualizedImage = Functions.histogramEqualizeImage(image);

subplot(3,2,5), imshow(histogramEqualizedImage), title([imageName, ' After Histogram Equalization']); %show histogram equalized input image in subplot
subplot(3,2,6), hist(histogramEqualizedImage(:),0:255), title([imageName, ' Histogram After Histogram Equalizationg']); %show histogram equalized input image histogram in subplot


fprintf('min pixel value of original image = %d\n',min(image(:)));
fprintf('min pixel value of equalized image = %d\n',min(histogramEqualizedImage(:)));



