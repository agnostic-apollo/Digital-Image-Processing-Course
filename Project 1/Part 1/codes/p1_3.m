%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q1.pdf

%read image and apply a simple averaging filter both in spatial and frequency domian


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])


%read coins image as image
imageName = 'coins.png';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image = im2double(image);

image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg

subplot(3,3,1), imshow(image), title([imageName, ' Grayscale Image']); %show input image grayscale in subplot
subplot(3,3,2), imshow(Functions.extendedFFT(image),[]), title([imageName, ' Image 2D FFT Image']); %show input image fft in subplot



%create and apply filter in spatial domain

filter = ones(3,3);
filter = im2double(filter);
filter = filter/sum(abs(filter(:)));
imageSpatialFiltered = imfilter(image,filter(:));

subplot(3,3,4), imshow(imageSpatialFiltered,[]), title([imageName, ' Image with Filter in Spatial Domain']); %show input image after applying filter in spatial domain in subplot

%take fft of image created after applying filter in spatial domain
imageSpatialFilteredFFT = Functions.extendedFFT(imageSpatialFiltered);  
subplot(3,3,5), imshow(imageSpatialFilteredFFT,[]), xlabel('X'), ylabel('Y'), axis on, title([imageName, ' Image with Filter in Spatial Domain 2D FFT']); %show input image after applying filter in spatial domain fft in subplot

%subplot(3,3,4), imshow(filter), title([imageName, 'Filter Image']); %show filter image in subplot



%create and apply filter in frequency domain

%image = Functions.makeImageDimensionsOdd(image); %make image dimensions odd
filter = ones(3,3);
filter = im2double(filter);
filter = filter/sum(abs(filter(:)));

[M,N]=size(image);
[O,P]=size(filter);

%filter will be at top left and append zeroes to the right and below it
%this is done to make it same dimensions as image
p1 = abs(M-O);
p2 = abs(N-P);
filter = padarray(filter,[p1 p2],0,'post');

[O,P]=size(filter);

%fprintf('I %d %d\n',M,N);
%fprintf('F %d %d\n',O,P);

%take fft of input image and filter
imageFFT = fft2(image);
filterFFT = fft2(filter);

%apply filter by simple multiplication as done in frequecy domain
imageFrequencyFilteredFFT = imageFFT .* filterFFT;

%take ifft of (fft of input image * fft of filter) to get input image after applying filter in spatial domain
imageFrequencyFiltered =  abs(ifft2(fftshift(imageFrequencyFilteredFFT)));

%imageFrequencyFiltered(end,:) = []; %delete last row
%imageFrequencyFiltered(:,end) = []; %delete last column
%imageFrequencyFiltered=imageFrequencyFiltered/2.5239;
%imageFrequencyFiltered=imageFrequencyFiltered-imageSpatialFiltered;

%take fft of filter just for displaying
filterFFT = Functions.extendedFFT(filter);
subplot(3,3,6), imshow(filterFFT,[]), xlabel('X'), ylabel('Y'), axis on, title('Filter 2D FFT'); %show filter fft in subplot


subplot(3,3,7), imshow(imageFrequencyFiltered,[]), title([imageName, ' Image with Filter in Freq Domain']); %show input image after applying filter in frequency domain in subplot

%retake fft of coins image after applying filter in frequency domain, same as imageFrequencyFilteredFFT
subplot(3,3,8), imshow(Functions.extendedFFT(imageFrequencyFiltered),[]), title([imageName, ' Image with Filter in Freq Domain 2D FFT']); %show input image after applying filter in frequency domain fft in subplot

