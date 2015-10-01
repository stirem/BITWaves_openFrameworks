
#include "touchObject.h"

// --------------------------------------------------------
///< Constructor for Touchobject
Touchobject::Touchobject()
{

}
// --------------------------------------------------------


// --------------------------------------------------------
void Touchobject::Setup()
{
    // Set spectrum values to 0
    for (int i = 0; i<BANDS; i++) {
        spectrum[i] = 0.0f;
    }
    
    soundBrightness     = 0;
    alpha               = 255;
    startRadius         = 0;
    spectrumVolume      = 0;
    colorBrightness     = 0;
    radius              = 0;
    
}
// --------------------------------------------------------


// --------------------------------------------------------
void Touchobject::Update( float *val, float volume )
{
    // Sound spectrum
    for (int i = 0; i<BANDS; i++)
    {
        spectrum[i] *= 0.97; // Slow decreasing
        spectrum[i] = max( spectrum[i], val[i]);
    }
    // --------------------
    
    
    // --------------------
    ///< Get average value from sound spectrum
    float a = 0;
    float b = 0;
    
    for ( int i = 0; i<BANDS; i++ )
    {
        a += ( i + 1 ) * spectrum[i];
        b += spectrum[i];
    }
    
    // Avoid division by 0 for silence
    if ( a == 0 )
        b = 1;
    
    soundBrightness = a / b;
    spectrumVolume = b;
    // --------------------

    
    // Fade down soundobject when not playing
    if ( spectrumVolume < 1000 )
    {
        if ( colorBrightness > 0 )
        {
            colorBrightness = colorBrightness - 5;
        }
        if( alpha > 0 ) alpha = alpha - 5;
        
        if ( radius >= 0 ) {
            radius = radius - 1;
        }
        
    } else {
        alpha = 255;
    }
    
    ofLog() << "touch object alpha: " << alpha;
    

}
// --------------------------------------------------------


// --------------------------------------------------------
float Touchobject::SpectrumVolume()
{
    return spectrumVolume;
}
// --------------------------------------------------------


// --------------------------------------------------------
float Touchobject::SoundBrightness()
{
    return soundBrightness;
}
// --------------------------------------------------------


// --------------------------------------------------------
float Touchobject::ColorBrightness()
{
   
    colorBrightness = ofMap( soundBrightness, 500, 770, 255, 20 );
    
    return colorBrightness;
    
}
// --------------------------------------------------------


// --------------------------------------------------------
float Touchobject::StartRadius()
{
    
    ///< Start radius for soundwaves based on the size of the soundobject.
    //startRadius = spectrumVolume / 30;
   
    

    //startRadius = ofMap( spectrumVolume, 1300, 1600, 10, 30 );
    startRadius = ofMap( spectrumVolume, 1300, 1600, ofGetScreenWidth() * 0.01, ofGetScreenWidth() * 0.02 );
    
    radius = startRadius;
    
    
    return startRadius;
    
}
// --------------------------------------------------------


// --------------------------------------------------------
void Touchobject::Position( float touchX, float touchY )
{
    pos.set(touchX, touchY);
}
// --------------------------------------------------------


// --------------------------------------------------------
void Touchobject::Draw()
{
    //ofEnableAlphaBlending();
    //OF_BLENDMODE_SCREEN;

    color = ofColor( 255, 255, 255, alpha );
    //color.setBrightness(mySpecVolume / 20);
    color.setBrightness( colorBrightness );
    ofSetColor( color );
    ofSetCircleResolution( 100 );
    ofFill();
    ofCircle( pos.x, pos.y, radius );


    
    ///< Spectrum
    /*ofSetColor(100, 100, 100);
    for (int i = 0; i < BANDS; i++) {
        ofRect(5 + i * 2, ofGetHeight(), 1, -spectrum[i] * 10);
    }*/

    
}
// --------------------------------------------------------





