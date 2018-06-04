function functions = Functions
    functions.readImageFromFile=@readImageFromFile;
    functions.readImageFromMatFile=@readImageFromMatFile;
    functions.convertToGrayScale=@convertToGrayScale;
    functions.contrastStretchImage=@contrastStretchImage;
    functions.histogramEqualizeImage=@histogramEqualizeImage;
    functions.extendedFFT=@extendedFFT;
    functions.extendedIFFT=@extendedIFFT;
    functions.createNoiseImage=@createNoiseImage;
    functions.standtardDeviationOfImage=@standtardDeviationOfImage;
    functions.medianFilter=@medianFilter;
    functions.createCheckerboardAndConstantGrayLevelStripesImage=@createCheckerboardAndConstantGrayLevelStripesImage;
    functions.gammaCorrectImage=@gammaCorrectImage;
    functions.findIntegerFactorsCloseToSquarRoot=@findIntegerFactorsCloseToSquarRoot;
    functions.findBestSubplotDimensions=@findBestSubplotDimensions;
end


%read image from file and return false if failed
function image = readImageFromFile(imageName)
    if exist(imageName, 'file') == 2
        image = imread(imageName);  %read image
    else
        fprintf('%s does not exist\n', imageName);
        image = [];
    end
end


%read image from mat and return false if failed
function image = readImageFromMatFile(matName,imageName)
    if exist(matName, 'file') == 2
        mat = load(matName); %load mat
        if isempty(who('-file', matName, imageName))
          fprintf('%s does not exist in %s\n', imageName, matName);
          image = [];
        else
          image = mat.(imageName);
          if isempty(image)
            fprintf('%s is empty\n', imageName);
          end
        end     
    else
        fprintf('%s does not exist\n', imageName);
        image = [];
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


%find fft
function fftImage = extendedFFT(image)
    fftImage = fft2(image);
    fftImage = fftshift(fftImage); %center the fft
    fftImage = abs(fftImage); %find magnitude of real and imaginary
    fftImage = log(fftImage+1); %scale down or decrease the dynamic range of the fft
    fftImage = mat2gray(fftImage); %scale the image between 0 and 1
end


%find ifft
function ifftImage = extendedIFFT(image, type)
    if(strcmp(type,'abs')==1)
        ifftImage = abs(ifft2(ifftshift(image)));
    elseif(strcmp(type,'real')==1)
        ifftImage = real(ifft2(ifftshift(image)));
    else
        ifftImage = ifft2(ifftshift(image));
    end
end


%function to add rows and columns to input image to make its dimensions odd if needed
function oddDimensionedImage = makeImageDimensionsOdd(image)
    [M,N]=size(image);
    if(mod(M,2)==0 && mod(N,2)==0) %add 1 row and 1 column if M and N are even
        oddDimensionedImage = padarray(image,[1 1],0,'post');
    elseif(mod(M,2)~=0 && mod(N,2)==0) %add 1 column if only N is even
        oddDimensionedImage = padarray(image,[0 1],0,'post');
    elseif(mod(M,2)==0 && mod(N,2)~=0) %add 1 row if only M is even
        oddDimensionedImage = padarray(image,[1 0],0,'post');    
    else %dont add anything if both M and N are odd
        oddDimensionedImage = image;              
    end
end

%function to create normally distributed M*N dimensional noise
function noise = createNoiseImage(M, N, standardDeviation, mean)
      noise = standardDeviation.*randn(M,N) + mean;
end


%function to find standard deviation of image
function standardDeviation = standtardDeviationOfImage(image)
    image = image(:);
    standardDeviation = sqrt(sum((image - mean2(image)).^2)/length(image));
    %standardDeviation = std2(image);
end


%function to apply median filter with 3x3 kernel to input image
function medianFilteredImage = medianFilter(image)
    medianFilteredImage = image;
    [M1,N1] = size(medianFilteredImage);
    if M1<3 || N1<3 % return if dimensions of image less than 3x3
        return;
    end
    
    image = makeImageDimensionsOdd(image);
    medianFilteredImage = image;
    [M2,N2] = size(medianFilteredImage);
    for i=2:M2-1
      for j=2:N2-1
        selectedPoints = image(i-1:i+1,j-1:j+1);
        medianFilteredImage(i,j) = median(selectedPoints(:));
      end
    end
    medianFilteredImage = medianFilteredImage(1:M1,1:N1);
end


%function to create an image with alternating checkboard pattern and constant gray level stripes with M*N dimensions
function image = createCheckerboardAndConstantGrayLevelStripesImage(grayLevel, M, N)
    %make dimesion M(height) a multiple of 32 as one alternating pattern of both stripes has height and width of 32
    M = round(M / 32) * 32;
    %make dimesion N(width) a multiple of 4 as  pattern has width of 4
    N = round(N / 4) * 4;

    %create checkerboard pattern
    %255  255   0   0
    %255  255   0   0
    % 0    0   255 255
    % 0    0   255 255
    checkerboardPattern = [255 255 0 0;...
                         255 255 0 0;...
                         0 0 255 255;...
                         0 0 255 255];
    
    %create constant gray level pattern
    %constantGrayLevelPattern = ones(4,4)*grayLevel;
    constantGrayLevelPattern = [grayLevel grayLevel grayLevel grayLevel;...
                                grayLevel grayLevel grayLevel grayLevel;...
                                grayLevel grayLevel grayLevel grayLevel;...
                                grayLevel grayLevel grayLevel grayLevel];
     
     %repeat checkerboard pattern and constant grayscale matrix 4 times to create height of 16 pixels
     %iterate 2 times and not 4 since height would already be 8 in second loop
     for z=1:2
        checkerboardPattern = vertcat(checkerboardPattern, checkerboardPattern);
        constantGrayLevelPattern = vertcat(constantGrayLevelPattern, constantGrayLevelPattern);
     end                       
                            
     %create a stripe of N column of repeating patterns by appending horizontally                        
     checkerboardPatternStripe = checkerboardPattern;
     constantGrayLevelPatternStripe = constantGrayLevelPattern;

     for z=1:(N/4)-1
       checkerboardPatternStripe = horzcat(checkerboardPatternStripe, checkerboardPattern);
       constantGrayLevelPatternStripe = horzcat(constantGrayLevelPatternStripe, constantGrayLevelPattern);
     end
     
     %create an image of M rows by appending alternating stripes vertically                        
     image = vertcat(checkerboardPatternStripe, constantGrayLevelPatternStripe);
        
     for z=1:(M/32)-1
       image = vertcat(image, checkerboardPatternStripe);
       image = vertcat(image, constantGrayLevelPatternStripe);
     end

end


%function to gamma correct the input image
%gamma corrected image = ((image/255)^gamma) * 255
function gammaCorrectedImage = gammaCorrectImage(image, gamma)
    gammaCorrectedImage = ((floor(double(image))/255).^gamma)*255;    
end


%function to find two integer factors of n closest to its square root
function [a, b] =  findIntegerFactorsCloseToSquarRoot(n)
    % a cannot be greater than the square root of n
    % b cannot be smaller than the square root of n
    % we get the maximum allowed value of a
    amax = floor(sqrt(n));
    if 0 == rem(n, amax)
        % special case where n is a square number
        a = amax;
        b = n / a;
        return;
    end
    % Get its prime factors of n
    primeFactors  = factor(n);
    % Start with a factor 1 in the list of candidates for a
    candidates = [1];
    for i=1:numel(primeFactors)
        % get the next prime factr
        f = primeFactors(i);
        % Add new candidates which are obtained by multiplying
        % existing candidates with the new prime factor f
        % Set union ensures that duplicate candidates are removed
        candidates  = union(candidates, f .* candidates);
        % throw out candidates which are larger than amax
        candidates(candidates > amax) = [];
    end
    % Take the largest factor in the list d
    a = candidates(end);
    b = n / a;
end


%find dimensions of a subplot that will almost create a sqaure if n items are to be added to subplot
function [j, k] =  findBestSubplotDimensions(n)
    if mod(n,2)==0
       [j,k] = findIntegerFactorsCloseToSquarRoot(n);
    else
       [j,k] = findIntegerFactorsCloseToSquarRoot(n+1);
    end
end

