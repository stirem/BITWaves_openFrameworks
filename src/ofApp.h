#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"

#include "particles.h"
#include "touchObject.h"
#include "menuButton.h"

#include "ofxMaxim.h" // Include Maximilian in project
#include "maximilian.h" // Inclde Maximilian in project


#define NR_OF_SOUNDS 9




class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    

    
    
		vector<Particles> particles; // Soundwave vector
	
		Touchobject touchobject; // Touchobject ??
    
		Button button;
    
    
		float touchPosX;
		float touchPosY;
		bool  triggerPlay;
		float soundSpeed;
		bool  fingerIsLifted;


    
    
    ///< MAXIMILIAN
    // REMEMBER TO INCLUDE ACCELERATE FRAMEWORK !
    // Build phases -> Link Binary With Libraries -> + -> Accelerate Framework
    //void audioReceived( float * input, int bufferSize, int nChannels );
	
	int	  initialBufferSize;
	int	  sampleRate;
	float panning;
	float volume;
	
	/** Called every time there is a request to calculate a new audio vector.
	 @param output			The audio vector
	 @param bufferSize		Audio vector size
	 @param nChannels		Number of audio channels
	 */
	void  audioRequested( float * output, int bufferSize, int nChannels );

    
    // Maximilian sample playback declaration
    ofxMaxiSample fileSample[NR_OF_SOUNDS];
    
    
    // Declare FFT
    int fftSize;
    int nAverages;
    ofxMaxiFFT myFFT;
    //ofxMaxiFFTOctaveAnalyzer myFFTOctAna;

    
};


