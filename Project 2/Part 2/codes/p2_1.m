%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in section 4 of Gamma.pdf and Proj2_Q2.pdf

%create a checkerboard and constant grayscale stripes image and display it for an experiment to estimate a screen's gamma correction
%screen's gamma can be found by when perceived intensity of checkerboard pattern(left) is equal to perceived intensity of constant gray scale pattern(right).
% (I255 + 0)/2 = I255(g/255)^?
% 1/2 = (g/255)^?
% ? * log(g/255) = log(0.5)
% ? = log(0.5)/log(g/255)
%in my case gray scale level g = 186 which results in ? = 2.19


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])


grayLevel = 186; %set grayscale level for grayscale stripes

image = Functions.createCheckerboardAndConstantGrayLevelStripesImage(grayLevel, 256, 256); %create checkerboard and constant grayscale stripes image

subplot(1,1,1), imshow(image,[0 255]), title(['Checkboard And Gray Level = ' ,num2str(grayLevel), ' Stripes Image']); %show checkerboard and constant grayscale stripes image in subplot

