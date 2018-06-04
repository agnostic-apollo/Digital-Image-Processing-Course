%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q1.pdf

%read cameraman image and show its fft
%read Cam1b image from DIP1.mat which is cameraman image with a pattern added
%recover original image from Cam1b image


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures
figure('units','normalized','outerposition',[0 0 1 1])

%read cameraman image as image1
imageName1 = 'cameraman.tif';
image1 = Functions.readImageFromFile(imageName1);
if isempty(image1)
    return; 
end
%image = im2double(image);
image1 = Functions.convertToGrayScale(image1); %convert image to grayscale if rbg

%find fft of cameraman image
image1FFT = Functions.extendedFFT(image1);

subplot(3,3,1), imshow(image1), title([imageName1, ' Grayscale Image']); %show cameraman image grayscale in subplot
subplot(3,3,2), imshow(image1FFT,[]), xlabel('X'), ylabel('Y'), axis on, title([imageName1, ' Image 2D FFT Image']); %show cameraman image fft in subplot
subplot(3,3,3), plot(image1FFT), xlabel('Frequency'), ylabel('Amplitude'), axis on, title([imageName1, ' Image 2D FFT Graph']); %show cameraman image fft graph in subplot



%read Cam1b image as image2
matName = 'DIP1.mat';
imageName2 = 'Cam1b';
image2 = Functions.readImageFromMatFile(matName, imageName2);
if isempty(image2)
    return; 
end
%image = im2double(image);
image2 = Functions.convertToGrayScale(image2); %convert image to grayscale if rbg

%find fft of Cam1b image
image2FFT = Functions.extendedFFT(image2); %find fft

subplot(3,3,4), imshow(image2), title([imageName2, ' Grayscale Image']); %show Cam1b image grayscale in subplot
subplot(3,3,5), imshow(image2FFT,[]), xlabel('X'), ylabel('Y'), axis on, title([imageName2, ' Image 2D FFT']); %show Cam1b image fft in subplot
subplot(3,3,6), plot(image2FFT), xlabel('Frequency'), ylabel('Amplitude'), axis on, title([imageName2, ' Image 2D FFT Graph']); %show Cam1b image fft graph in subplot


%find difference of cameraman and Cam1b images
%this part is just for understanding
image3FFT=image2FFT-image1FFT;

subplot(3,3,7), imshow(Functions.extendedIFFT(image3FFT,'abs'),[]), title('Difference Grayscale Image'); %show difference image grayscale in subplot
subplot(3,3,8), imshow(image3FFT,[]), xlabel('X'), ylabel('Y'), axis on, title('Difference Image 2D FFT'); %show difference image fft in subplot
subplot(3,3,9), plot(image3FFT), xlabel('Frequency'), ylabel('Amplitude'), axis on, title('Difference Image 2D FFT Graph'); %show difference image fft graph in subplot



%recover orignal image from Cam1b image
figure('units','normalized','outerposition',[0 0 1 1]) %create new figure

%take simple fft
image2FFT = fft2(image2); 
image2FFT = fftshift(image2FFT);


%find second and third largest freq and 0 them out
sorted = sort(image2FFT(:));
max1 = sorted(end);
max2 = sorted(end-1);
max3 = sorted(end-2);

%max1 = max(image2FFT(:));
%max2 = max( image2FFT(image2FFT(:) < max1));
%max3 = max( image2FFT(image2FFT(:) < max2));

fprintf('%f\n',max1);
fprintf('%f\n',max2);
fprintf('%f\n',max3);
[M,N]=size(image2FFT);
  for i=1:M
      for j=1:N
          if image2FFT(i,j)==max2
               fprintf('%d, %d = %f\n', i, j, image2FFT(i,j));
               image2FFT(i,j)=0;       
          elseif image2FFT(i,j)==max3
               fprintf('%d, %d = %f\n', i, j, image2FFT(i,j));
               image2FFT(i,j)=0;       
          end
      end
  end
  
  
%take ifft of modified image to get the recovered grayscale image
recoveredImage = Functions.extendedIFFT(image2FFT,'abs');

%retake fft of recovered grayscale image just for displaying purposes
recoveredImageFFT = Functions.extendedFFT(recoveredImage);
            
subplot(3,3,1), imshow(recoveredImage,[]), title([imageName1, ' Recovered Grayscale Image']); %show recovered image grayscale in subplot
subplot(3,3,2), imshow(recoveredImageFFT,[]), xlabel('X'), ylabel('Y'), axis on, title([imageName1, ' Recovered Image 2D FFT']); %show recovered image fft in subplot
subplot(3,3,3), plot(recoveredImageFFT), xlabel('Frequency'), ylabel('Amplitude'), axis on, title([imageName1, ' Recovered Image 2D FFT Graph']); %show recovered image fft graph in subplot
              

