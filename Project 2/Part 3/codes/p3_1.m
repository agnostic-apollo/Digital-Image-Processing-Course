%usage info:
%to use with octave on linux run "sudo apt-get install octave octave-image" then "octave" then "pkg load image" then "filename" without ".m"

%uncomment following line to plot figures if there is no opengl support when using octave 
%example when running script over vnc on chrooted linux on android phones
%comment following line if using matlab

%graphics_toolkit ("gnuplot")


%objective:
%more info in section 4 of PCA.pdf and Proj2_Q3.pdf

%display sample data
%find eigenvectors and eigenvalues and project sample data onto the eigenvectors
%plot first 10 projected values of alphabets a,b,c,d in a graph
%display eigenimages of 12 largest eigenvectors
%project data to different nth largest eigenvectors and display first image of dataset after pca reconstruction for each n


%code begin:
%assign all functions in Functions.m to Functions
clear Functions; %clear cache
Functions = Functions;

%close all; %close all figures


%reads in a set of training images
%the images are sets of English letters written in various fonts.  
%each image is reshaped and placed into a column of a data matrix, "X"

% The following are strings used to assemble the data file names
datadir='training_data/';    % directory where the data files reside
dataset={'arial','bookman_old_style','century','comic_sans_ms','courier_new',...
  'fixed_sys','georgia','microsoft_sans_serif','palatino_linotype',...
  'shruti','tahoma','times_new_roman'};
datachar='abcdefghijklmnopqrstuvwxyz';

Rows=64; %set sample data image height
Cols=64; %set sample data image width
n=length(dataset)*length(datachar); %set total number of images in sample data
p=Rows*Cols; %set total number of pixels per image

%read sample data
%each image is added as a new column of X
X=zeros(p,n); 
k=1;
for dset=dataset
    for ch=datachar
      fname=sprintf('%s/%s/%s.tif',datadir,char(dset),ch);
      img=imread(fname);
      X(:,k)=reshape(img,1,Rows*Cols);
      k=k+1;
    end
end


figure('Name','Sample Data','NumberTitle','off','units','normalized','outerposition',[0 0 1 1])

%display samples of the training data, alphabet a with different fonts
for k=1:length(dataset)
  img=reshape(X(:,26*(k-1)+1),64,64);
  subplot(3,4,k), imagesc(img), axis('image'), title(dataset{k}, 'Interpreter','none'), colormap(gray(256)); %show sample data image in subplot
end



%find mean of dataset
avg = mean(X);

%center the data by substracting mean of entire dataset from each image
X = X-repmat(avg, size(X, 1), 1);

%normalize the data
%covariance = cov(X);
%stdev = sqrt(diag(covariance));
%X = X./repmat(stdev', size(X, 1), 1);

%find eigenvectors and eigenvalues
[u,d,v] = svd(X,0);
eigenvalues = diag(fliplr((d)));
eigenvectors = fliplr(u);

eigenvectorsCount = size(eigenvectors,2);


%decorrelate the data by projecting data on all eigenvectors computed
%PC projections = data * eigenvectors, taking transpose of X for valid multiplication
projectedX = X' * eigenvectors;


%plot first 10 projections of first 4 images
figure('Name','Projection Plots','NumberTitle','off','units','normalized','outerposition',[0 0 1 1])
x = [1,2,3,4,5,6,7,8,9,10];
for i=1:4
    hold on 
    y = projectedX(i,1:10);
    plot(x,y, 'Marker', '.', 'LineStyle', '-'); %plot xth projected of i in subplot 
end
legend('a', 'b', 'c', 'd');



%display eigenimages of largest 12 eigenvectors
n=12;

nthLargestEigenvectors=eigenvectors(:,eigenvectorsCount-n+1:eigenvectorsCount);

%find best dimensions of the new subplot to create a squarish subplot
[j,k] = Functions.findBestSubplotDimensions(n);

%display eigenimages
figure('Name','Eigen Images','NumberTitle','off','units','normalized','outerposition',[0 0 1 1])
for i=1:n
    eigenImage = reshape( nthLargestEigenvectors(:,i), [64,64]); %get ith column and reshape it to 64x64 image
    subplot(j,k,i), imagesc(eigenImage), title(['Eigen image ' ,num2str(i)]), colormap(gray(256)), axis square; %show eigenimage in subplot
end

clear eigenImage; %clear to free memory



%project data to nth largest eigenvectors and display first image of dataset after pca reconstruction for each n
values = [1,5,12,15,20,30];

figure('Name','Image Reconstruction','NumberTitle','off','units','normalized','outerposition',[0 0 1 1])

%find best dimensions of the new subplot to create a squarish subplot
[j,k] = Functions.findBestSubplotDimensions(size(values,2) + 1);

%orignal first image
firstImage = reshape( X(:,1), [64,64]); %get 1st column and reshape it to 64x64 image
subplot(j,k,1), imagesc(firstImage), title('Orignal Image'), colormap(gray(256)), axis square; %show original first image in subplot
  
%for each n in values
for i = 1:size(values,2)
  n = values(i);
  
  nthLargestEigenvectors=eigenvectors(:,eigenvectorsCount-n+1:eigenvectorsCount);
  
  %project data onto eigenvectors
  %PC projections = data * eigenvectors, taking transpose of X for valid multiplication
  projectedX = X' * nthLargestEigenvectors;
  
  %reconstruct orignal data from projected data
  %PC reconstruction = PC projections * transpose(eigenvectors) + mean, taking transpose of mean for valid multiplication
  reconstructedX = projectedX * nthLargestEigenvectors' + repmat(avg, size(X, 1), 1)';
  %reconstructedX = reconstructedX'; %if you need each image into columns instead of rows

  
  %reconstructed first image with n eigenvectors
  firstImage = reshape( reconstructedX(1,:), [64,64]); %get 1st column and reshape it to 64x64 image
  subplot(j,k,i+1), imagesc(firstImage), title([num2str(n), ' Largest eigenvectors']), colormap(gray(256)), axis square; %show pca reconstructed image in subplot
  
end

