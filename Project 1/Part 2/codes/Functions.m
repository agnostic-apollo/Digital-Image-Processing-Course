 function functions = Functions
  functions.readImageFromFile=@readImageFromFile;
  functions.convertToGrayScale=@convertToGrayScale;
  functions.contrastStretchImage=@contrastStretchImage;
  functions.histogramEqualizeImage=@histogramEqualizeImage;
 end

%read image from file and return false if failed
function imageFile = readImageFromFile(imageName)
    if exist(imageName, 'file') == 2
        imageFile = imread(imageName);  %read image
    else
        fprintf('%s does not exist\n', imageName);
        imageFile = [];
    end
end
 
%function to convert image to grayscale if input image is rbg
function grayScaleImage = convertToGrayScale(image)
    if size(image,3)==3
         grayScaleImage = rgb2gray(image); %convert image to grayscale
    else
        grayScaleImage = image;
    end
end


%function to contrast stretch the input gray image between 0-255
%lowerSaturationLimit>=0 higherSaturationLimit<=1
%set lowerSaturationLimit=0 && higherSaturationLimit=1 if saturation not needed
function contrastStretchedImage = contrastStretchImage(grayImage, lowerSaturationLimit, higherSaturationLimit)

    grayImage = uint8(255 * mat2gray(grayImage)); %change range to 0-255
    
    [M,N]=size(grayImage);
    p=zeros(1,256);

    %find probabilities of pixel values of grayscale image
      for i=1:M
          for j=1:N
              p(grayImage(i,j)+1) = p(grayImage(i,j)+1) + 1;
          end
      end
    for z=1:256
        p(z)=p(z)/(M*N);
    end

    %find pixel value for lower saturation limit
    percentile = 0;
    for z=1:256
        if percentile > lowerSaturationLimit
            break
        end
        percentile = percentile + p(z);
    end
    oldMin=z-1;


    %find pixel value for higher saturation limit
    percentile = 0;
    for z=1:256
        if percentile > higherSaturationLimit
            break
        end
        percentile = percentile + p(z);
    end
    oldMax=z-1;


    %oldMin = min(grayImage(:));  %find min pixel value of the image
    %oldMax = max(grayImage(:));  %find max pixel value of the image

    newMin = 0;
    newMax = 255;

    %Iout = (Iin-c)(b-a/d-c) + a 
    %where b and a are max and min values to constract stretch to
    %d and c are max and min values in the input image

    contrastStretchedImage = ((grayImage - oldMin) * ( (newMax-newMin) / (oldMax-oldMin) ) ) + newMin; %apply formulae

    %use matlab default contrast stretching with 1% saturation
    %same as custom code written before
    %contrastStretchedImage = imadjust(grayImage,stretchlim(grayImage),[]);

end


%function to histogram equalize the input gray image
function histogramEqualizedImage = histogramEqualizeImage(grayImage)

    grayImage = uint8((255 * mat2gray(grayImage))+1); %change range to 1-256

    [M,N]=size(grayImage);
    p=zeros(1,256);

    %find probabilities of pixel values of grayscale image
      for i=1:M
          for j=1:N
              p(grayImage(i,j)+1) = p(grayImage(i,j)+1) + 1;
          end
      end
    for z=1:256
        p(z)=p(z)/(M*N);
    end


    %find discrete approximations of probability distributions/cdf
    g=zeros(1,256);
    g(1) = p(1);
    for z=2:256
      g(z) = g(z-1) + p(z);
    end


    %find gmin
    for z=1:256
        if g(z) > 0
            break
        end
    end
    gmin=g(z);


    %find gmax
    for z=1:256
        if g(z) >=1
            break
        end
    end
    gmax=g(z);


    %format long
    %disp(p)
    %disp(g)
    %disp(gmin)
    %disp(gmax)

    %histogramEqualizedImage = ((gi - gmin) * ( 255 / (gmax-gmin) ) ); %apply formulae
    histogramEqualizedImage=grayImage;

    for i=1:M
      for j=1:N
              histogramEqualizedImage(i,j) = round( ( g(histogramEqualizedImage(i,j)) - gmin ) * (255 / (gmax-gmin)) );
      end
    end

    histogramEqualizedImage = uint8(255 * mat2gray(histogramEqualizedImage)); %change range back to 0-255

    %matlab histogram equalization function
    %histogramEqualizedImage = histeq(grayImage);

end
