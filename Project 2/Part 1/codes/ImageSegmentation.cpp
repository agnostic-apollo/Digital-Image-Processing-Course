#include <iostream>
#include<fstream>
#include<vector>
#include<algorithm>
#include<sstream>
#include<string>
#include <queue>
#include <math.h>
#include <unordered_set>
#include <set>
#include "tiff.h"
#include "tiff.c"

//info of objective is in CCSeg.pdf and Proj2_Q1.pdf

using namespace std;

struct pixel{
    int i,j;
    pixel(){};
    pixel(int i, int j)
    {
        this->i=i; this->j=j;
    }

    bool operator==(const pixel &other) const
    { return (i == other.i && j == other.j); }
};

class pixelHash {
    public:
       size_t operator() (const pixel &p) const {
            size_t ret = p.i;
            ret *= 2654435761U;
            return ret ^ p.j;
       }
};

class pixelCompare {
	public:
		bool const operator()(const pixel &p1, const pixel &p2) {
			return (p1.i < p2.i && p1.j < p2.j);
		}
};

void readGrayScaleTIFFImage(string, vector< vector<double> >&, int&, int& );
void writeGrayScaleTIFFImage(string, vector< vector<double> >&);
vector<pixel> fourPointNeighbourhoodSystem();
vector<pixel> eightPointNeighbourhoodSystem();
vector<pixel> ConnectedNeighbours(struct pixel , double , vector< vector<double> >&, vector<pixel>& );
void ConnectedSet(struct pixel , double , vector< vector<double> >& , vector<pixel>&, int&, vector< vector<double> >&, int,  unordered_set< pixel, pixelHash >& );
vector< vector<double> > ImageSegmentation(vector< vector<double> >& , vector<pixel> &, double, int );
void rescaleImageBetween0and255(vector< vector<double> >&);


int main()
{
    string inputFilename = "img22gd2.tif"; //set filename of input image
    string outputFilename = "segmented-" + inputFilename; //set filename of output image

    int imageWidth, imageHeight;
    vector< vector<double> > image;

    //read grayscale image
    readGrayScaleTIFFImage(inputFilename, image, imageWidth, imageHeight);

    //create neighbourhood system
    vector<pixel> neighbourhoodSystem = fourPointNeighbourhoodSystem();
    //vector<pixel> neighbourhoodSystem = eightPointNeighbourhoodSystem();



    double threshold = 2; //set threshold for forming connectedSet
    int minimumConnectedSetSize = 1; //set minimum size a connectedSet can be

    //uncomment any one of the start/end sections

    //segment entire image

    //start
    vector< vector<double> > segmentedImage = ImageSegmentation(image, neighbourhoodSystem, threshold, minimumConnectedSetSize);
    //end


    //OR


    //find connected set of a pixel
/*
    //start
    int SetLabel=255; //set label to assign to connected set of the pixel
    pixel p(67,45); //set indices of pixel for which connected set is to be formed

    unordered_set< pixel, pixelHash > unsegmented_pixels;
    vector< vector<double> > segmentedImage(imageHeight, vector<double> (imageWidth,-1));

    for(int i=0;i<imageHeight;i++)
        for(int j=0;j<imageWidth;j++)
            unsegmented_pixels.insert(pixel(i,j));

    ConnectedSet(p, threshold, image, neighbourhoodSystem, SetLabel, segmentedImage, minimumConnectedSetSize, unsegmented_pixels);
    //end
*/


    //rescale between 0 and 255 to increase contrast between regions if needed
    //rescaleImageBetween0and255(segmentedImage);

    //store image
    writeGrayScaleTIFFImage(outputFilename, segmentedImage);

}

void readGrayScaleTIFFImage(string filename, vector< vector<double> >& image, int& imageWidth, int& imageHeight)
{
    FILE *fp;
    struct TIFF_img input_img;

    int i,j;

    //open input image file
    fp = fopen(filename.c_str(), "rb");
    if (fp==NULL)
    {
        cout<<"cannot open file "<<filename<<endl;
        exit(1);
    }

    //read image
    if (read_TIFF(fp, &input_img))
    {
        cout<<"error reading file "<<filename<<endl;
        exit(1);
    }

    //close input image file
    fclose(fp);

    //check the type of image data
    if (input_img.TIFF_type !='g')
    {
        cout<<"error: image must be a gray scale image"<<endl;
        exit(1);
    }

    imageWidth = input_img.width;
    imageHeight = input_img.height;

    if(imageWidth < 1 || imageHeight < 1)
    {
        cout<<"error: invalid image dimensions"<<endl;
        exit(1);
    }

    image.clear();
    image.resize(imageHeight, vector<double> (imageWidth,0));

    //copy grayscale pixel values to vector
    for(i=0;i<imageHeight;i++)
        for(j=0;j<imageWidth;j++)
                image[i][j] = input_img.mono[i][j];

}
void writeGrayScaleTIFFImage(string filename, vector< vector<double> >&image)
{
    int imageWidth = image[0].size();
    int imageHeight = image.size();
    double pixelValue;
    FILE *fp;
    struct TIFF_img output_img;

    get_TIFF(&output_img, imageHeight, imageWidth, 'g');


    for(int i=0;i<imageHeight;i++)
    {
        for(int j=0;j<imageWidth;j++)
        {
            pixelValue = image[i][j];

            if(pixelValue>255)
                output_img.mono[i][j] = 255;
            else if(pixelValue<0)
                output_img.mono[i][j] = 0;
            else
                output_img.mono[i][j] = pixelValue;
        }
    }

    //open output image file
    fp = fopen(filename.c_str(), "wb");
    if (fp==NULL)
    {
        cout<<"cannot open file "<<filename<<endl;
        exit(1);
    }

    //read image
    if (write_TIFF(fp, &output_img))
    {
        cout<<"error writing TIFF file "<<filename<<endl;
        exit(1);
    }

    //close output image file
    fclose(fp);

}

vector<pixel> fourPointNeighbourhoodSystem()
{
    vector<pixel> neighbourhoodSystem(0);
    neighbourhoodSystem.push_back(pixel(0,-1)); //top
    neighbourhoodSystem.push_back(pixel(1,0)); //right
    neighbourhoodSystem.push_back(pixel(0,1)); //bottom
    neighbourhoodSystem.push_back(pixel(-1,0)); //left

    return neighbourhoodSystem;
}

vector<pixel> eightPointNeighbourhoodSystem()
{
    vector<pixel> neighbourhoodSystem(0);

    neighbourhoodSystem.push_back(pixel(0,-1)); //top
    neighbourhoodSystem.push_back(pixel(1,-1)); //top right
    neighbourhoodSystem.push_back(pixel(1,0)); //right
    neighbourhoodSystem.push_back(pixel(1,1)); //bottom right
    neighbourhoodSystem.push_back(pixel(0,1)); //bottom
    neighbourhoodSystem.push_back(pixel(-1,1)); //bottom left
    neighbourhoodSystem.push_back(pixel(-1,0)); //left
    neighbourhoodSystem.push_back(pixel(-1,-1)); //top left

    return neighbourhoodSystem;
}

vector< vector<double> > ImageSegmentation(vector< vector<double> >& image, vector<pixel> &neighbourhoodSystem, double threshold, int minimumConnectedSetSize)
{
    unordered_set< pixel, pixelHash > unsegmented_pixels; //set to store all pixels not part of any segment currently
    //set< pixel, pixelCompare > unsegmented_pixels;

    int imageWidth = image[0].size();
    int imageHeight = image.size();

    vector< vector<double> > segmentedImage(imageHeight, vector<double> (imageWidth,-1)); //the final segmented image to be returned

    //add all pixels to the set of unsegmented pixels
    for(int i=0;i<imageHeight;i++)
        for(int j=0;j<imageWidth;j++)
            unsegmented_pixels.insert(pixel(i,j));

    int SetLabel=0;

    //for all pixels not segmented yet call connectedSet on it
    while(unsegmented_pixels.size()>0)
    {
        auto it = unsegmented_pixels.begin();
        pixel p = *it;
        ConnectedSet(p, threshold, image, neighbourhoodSystem, SetLabel, segmentedImage, minimumConnectedSetSize, unsegmented_pixels);
    }

    cout<<endl<<SetLabel<<" segments created"<<endl;
    return segmentedImage;
}


void ConnectedSet(struct pixel center, double threshold, vector< vector<double> >& image, vector<pixel> &neighbourhoodSystem, int& SetLabel, vector< vector<double> >& segmentedImage, int minimumConnectedSetSize, unordered_set< pixel, pixelHash >& unsegmented_pixels)
{
    int imageWidth = image[0].size();
    int imageHeight = image.size();
    int i,j;
    vector< vector<bool> >visited(imageHeight, vector<bool> (imageWidth,false)); //boolean vector to store pixels that are part of a connected set
    vector<pixel> connectedSet(0); //vector to store all pixels part of connectedSet
    vector<pixel> connectedNeighbours(0); //temp vector to store all neighbours of the current pixel
    queue< pixel> pixelQueue; //queue used to iterate over all pixels to be part of connectedSet

    pixelQueue.push(center); //start connectedSet formation from the center pixel
    connectedSet.push_back(center); //add center pixel to the connectedSet vector
    visited[center.i][center.j] = true; //mark center pixel already visited
    pixel currentPixel;

    while(!pixelQueue.empty())
    {
        currentPixel = pixelQueue.front();
        pixelQueue.pop();

        //pop front pixel from pixelQueue and find pixels in its neighbourhood system and within the threshold
        connectedNeighbours = ConnectedNeighbours(currentPixel, threshold, image, neighbourhoodSystem);

        for(i=0;i!=connectedNeighbours.size();i++)
        {
            //if neighbour has not already been added to the connectedSet or not already part of any segment
            if(!visited[connectedNeighbours[i].i][connectedNeighbours[i].j] && unsegmented_pixels.find(pixel(connectedNeighbours[i].i, connectedNeighbours[i].j))!=unsegmented_pixels.end())
            {
                pixelQueue.push(connectedNeighbours[i]); //add it to the pixelQueue for future iteration
                connectedSet.push_back(connectedNeighbours[i]); //add it to the connectedSet of the center pixel
                visited[connectedNeighbours[i].i][connectedNeighbours[i].j] = true; //mark it as part of the connectedSet
            }
        }

    }

    int setLabel;
    if(connectedSet.size()>=minimumConnectedSetSize) //if the connectedSet created has size greater than the minimum limit assign a new label to it
    {
        SetLabel++;
        setLabel=SetLabel;
    }
    else //else assign it the default 0
        setLabel=0;

     for(i=0;i!=connectedSet.size();i++)
     {
        segmentedImage[connectedSet[i].i][connectedSet[i].j] = setLabel; //mark the connectedSet in segmentation image according to setLabel
        unsegmented_pixels.erase(pixel(connectedSet[i].i, connectedSet[i].j)); //remove all pixels in connectedSet from unsegmented pixels
     }
}

vector<pixel> ConnectedNeighbours(struct pixel center, double threshold, vector< vector<double> >& image, vector<pixel> &neighbourhoodSystem)
{
    vector<pixel> connectedNeighbors(0);

    double centerValue = image[center.i][center.j];
    double neighbourValue;
    int neighbourRow, neighbourColumn;
    int imageWidth = image[0].size();
    int imageHeight = image.size();

    //iterate over all neighbours in neighbourhood system
    for(int n=0;n!=neighbourhoodSystem.size();n++)
    {
        //find ith  and jth index of neighbour relative to center
        neighbourRow = center.i + neighbourhoodSystem[n].i;
        neighbourColumn = center.j + neighbourhoodSystem[n].j;

        if(neighbourColumn >= 0 && neighbourColumn < imageWidth //if neighbour is within image dimensions
                && neighbourRow >= 0 && neighbourRow < imageHeight)
        {
            neighbourValue =  image[neighbourRow][neighbourColumn]; //find neighbour value

            if(abs(centerValue - neighbourValue) <=  threshold) //if neighbour value within threshold add it to connected neighbours
            {
                connectedNeighbors.push_back(pixel(neighbourRow,neighbourColumn));
            }
        }
    }

    return connectedNeighbors;
}

void rescaleImageBetween0and255(vector< vector<double> >&image)
{
    int imageWidth = image[0].size();
    int imageHeight = image.size();
    double maxPixelValue = image[0][0];
    //find max value
    for(int i=0;i<imageHeight;i++)
    {
        for(int j=0;j<imageWidth;j++)
        {
            if(image[i][j]> maxPixelValue)
                maxPixelValue=image[i][j];
        }
    }
    //cout<<maxPixelValue<<endl;
    //image = (image/max)*255
    for(int i=0;i<imageHeight;i++)
    {
        for(int j=0;j<imageWidth;j++)
        {
           image[i][j] = floor((image[i][j]/maxPixelValue) * 255);
        }
    }
}


