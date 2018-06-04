%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q2.pdf

%read images and show their grayscale and histograms


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])


%read input image 1 as image
imageName = 'Wormhole.jpg';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image=imresize(image,0.5); %resize image 
%figure, imshow(image), title('Wormhole rgb'); %show image in new figure
image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg
%figure, imshow(image), title('Wormhole grayscale'); %show image in new figure

subplot(3,2,1), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot
subplot(3,2,2), hist(image(:),0:255), title([imageName, ' Histogram']); %show input image histogram in subplot


%read input image 2 as  image
imageName = 'Ferrari 458.jpg';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image=imresize(image,0.5); %resize image 
image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg

subplot(3,2,3), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot
subplot(3,2,4), hist(image(:),0:255), title([imageName, ' Histogram']); %show input image histogram in subplot


%read input image 3 as image
imageName = 'Sir Usman.jpg';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg

subplot(3,2,5), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot
subplot(3,2,6), hist(image(:),0:255), title([imageName, ' Histogram']); %show input image histogram in subplot


figure('units','normalized','outerposition',[0 0 1 1]) %create new figure

%read input image 4 as image
imageName = 'Orion Clouds.jpg';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image=imresize(image,0.5); %resize image 
image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg

subplot(3,2,1), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot
subplot(3,2,2), hist(image(:),0:255), title([imageName, ' Histogram']); %show input image histogram in subplot


