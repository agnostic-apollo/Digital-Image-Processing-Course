%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in Proj1_Q2.pdf

%read image and display probabilities of each pixel value


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;


%read input image as image
imageName = 'MyBadHist.jpg';
image = Functions.readImageFromFile(imageName);
if isempty(image)
    return; 
end
image = Functions.convertToGrayScale(image); %convert input image to grayscale if rbg


[M,N]=size(image);
p=zeros(1,256);


%find probabilities of pixel values of input image
  for i=1:M
      for j=1:N
          p(image(i,j)+1) = p(image(i,j)+1) + 1;
      end
  end
for z=1:256
    p(z)=p(z)/(M*N);
end

%print probabilities of pixel values of input image
count=0;
for z=1:256
     if p(z)~=0
         fprintf('%d = %f\t', z-1, p(z));
         count=count+1;
         if mod(count,5)==0
            fprintf('\n');
         end
     end
end

fprintf('\n');



