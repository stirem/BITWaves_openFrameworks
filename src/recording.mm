
#include "recording.h"

Recording::Recording() {
    
}


/*bool shouldRemove(RecParticles &p)
{
    if(p.radius <= 0 )return true;
    else return false;
}*/




void Recording::setup() {
    
    myTimer = 0;
    
    isRecording = false;
    
    //SetupAudioFile();
    
    myRecString = ofxNSStringToString( getAudioFilePath() ); // Init sound file
    
    /*recButtonPosX                   = ofGetScreenWidth() * 0.5;
    recButtonPosY                   = ofGetScreenHeight() * 0.5;
    recButtonRadius                 = ofGetScreenWidth() * 0.15;
    distanceToRecButton             = ofGetScreenWidth(); // Avoid rec button getting pushed on start*/
    
    recButtonPosX                   = ofGetWidth() * 0.5;
    recButtonPosY                   = ofGetHeight() * 0.5;
    recButtonRadius                 = ofGetWidth() * 0.15;
    distanceToRecButton             = ofGetWidth(); // Avoid rec button getting pushed on start
    
    recButtonColor                  = 100;
    muteAudioWhileRecording         = false;
    loadFileIsDone                  = false;
    

    /*if( !isFileInDir() )
    {
        readyToPlay = false;
        SetupAudioFile();
        willTakeRecording = true;
        showDeleteButton = false;
    }
    else
    {
        readyToPlay = true;
        willTakeRecording = false;
        showDeleteButton = true;
    }*/
    
    waitForSaveFileTime             = 0;
    willWaitForSave                 = false;

    mAveragePower                   = 0;
    mPeakPower                      = 0;
    meter                           = 0;
    addParticlesTimer               = 0;
    spectrumPosXinc                 = 0;
    
    delButtonIsPressed              = false;
    
    /*delButtonPosX                   = ofGetScreenWidth() * 0.95;
    delButtonPosY                   = ofGetScreenHeight() * 0.05;
    delButtonRadius                 = ofGetScreenWidth() * 0.02;
    distanceToDelButton             = ofGetScreenWidth();*/
    
    delButtonPosX                   = ofGetWidth() * 0.95;
    delButtonPosY                   = ofGetHeight() * 0.05;
    delButtonRadius                 = ofGetWidth() * 0.02;
    distanceToDelButton             = ofGetWidth();
    
    delButtonTime                   = 0;
    willWaitForDelButton            = false;
    eraseRecFileTimer               = 0;
    silenceWhenDeleting             = false;
    
    trashcan.loadImage( "trashcan.png" );
    hold.loadImage( "hold.png" );
}


void Recording::isRecSampleZero( long recSampleLength ) {
    
    ofLog() << "rec sample length: " << recSampleLength;
    
    if ( recSampleLength == 0 )
    {
        readyToPlay = false;
        SetupAudioFile();
        willTakeRecording = true;
        showDeleteButton = false;
    }
    else
    {
        readyToPlay = true;
        willTakeRecording = false;
        showDeleteButton = true;
        loadFileIsDone = true;
    }
    
}

void Recording::Update( float touchX, float touchY, bool touchIsDown, bool recModeOn ) {
    
    myTimer += ofGetLastFrameTime();
    
    
    //// REC BUTTON ////
    distanceToRecButton = sqrt(    (touchX - recButtonPosX) * (touchX - recButtonPosX) + (touchY - recButtonPosY) * (touchY - recButtonPosY)     ) ;
    
    if ( willTakeRecording ) {
        if ( recButtonRadius > distanceToRecButton ) {
            recButtonIsPressed = 1;
        }
        
        // Touch Up
        if ( !touchIsDown ) {
            recButtonIsPressed = 0;
            
            if ( isRecording ) {
                StopPressed();
            }
        }
        
        if ( recButtonIsPressed ) {
            RecordPressed();
        }
    }
    
    /*if ( willWaitForSave ) {
        if ( myTimer > waitForSaveFileTime + 1.0 ) {
            saveFileIsDone = 1;
            readyToPlay = 1;
            willWaitForSave = 0;
        }
    }*/

    
    //// DELETE BUTTON ////
    if ( delButtonIsPressed ) {
        
        eraseRecFileTimer += ofGetLastFrameTime();
        silenceWhenDeleting = true;
        
        if ( eraseRecFileTimer >= 1.0 ) {
            readyToPlay = false;
            SetupAudioFile();
            willTakeRecording = true;
            showDeleteButton = false;
            delButtonIsPressed = false;
        }
    }
    
    
    // Do not make sound or visuals when rec button is on
    if ( willTakeRecording && recModeOn ) {
        readyToPlay = 0;
    }

    
    
    /// LEVEL METERING ///
    
    [audioRecorder updateMeters];
    mAveragePower = [audioRecorder averagePowerForChannel:0];
    mPeakPower = [audioRecorder peakPowerForChannel:0];
    
    meter = ofMap(mAveragePower, -60, -30, 0, 100);
    //meter = ofMap(mPeakPower, -60, -30, 0, 100);
    
    
    // Rec Spectrum
    if ( isRecording ) {
        addParticlesTimer += ofGetLastFrameTime();
        if ( addParticlesTimer >= 0.01 ) {
            spectrumPosXinc++;
            recSpectrum.push_back( RecSpectrum( meter, spectrumPosXinc ) );
            addParticlesTimer = 0;
        }
    } else {

        spectrumPosXinc = 0;
        
        for ( int i = 0; i < recSpectrum.size(); i++) {
            recSpectrum.erase( recSpectrum.begin() + i );
        }
    
    }
    
    
    
    // Rec Circle particles
    /*
    if ( isRecording ) {
        addParticlesTimer += ofGetLastFrameTime();
        if ( addParticlesTimer >= 0.01 ) {
            recParticles.push_back( RecParticles( meter ) );
        }
    }
    
    
    for (int i = 0; i < recParticles.size(); i++) {
        recParticles[i].Update( isRecording );
    }
    
    ofRemove( recParticles, shouldRemove );
     */
    
}


void Recording::distanceToDeleteButton( float touchX, float touchY, bool recModeOn ) {
    
    //// DELETE BUTTON ////
    distanceToDelButton = sqrt(    (touchX - delButtonPosX) * (touchX - delButtonPosX) + (touchY - delButtonPosY) * (touchY - delButtonPosY)     ) ;
    
    if ( showDeleteButton ) {
        if ( delButtonRadius > distanceToDelButton )
        {
            delButtonIsPressed = true; // Is flagged false in ofApp::touchUp
            eraseRecFileTimer = 0;
        }
    }
    
}


void Recording::Draw() {
    
    // Rec circle particles
    /*for (int i = 0; i < recParticles.size(); i++) {
        recParticles[i].Draw();
    }*/
    
    // Rec spectrum
    for (int i = 0; i < recSpectrum.size(); i++) {
        recSpectrum[i].Draw();
    }
    
    // Rec button
    if ( willTakeRecording ) {
        ofSetColor( recButtonColor, 0, 0 );
        ofFill();
        ofCircle( recButtonPosX, recButtonPosY, recButtonRadius );
        ofSetColor( 255, 255, 255, 20 );
        hold.setAnchorPercent( 0.5, 0.5 );
        hold.draw( recButtonPosX, recButtonPosY, recButtonRadius, recButtonRadius * 0.29 );
    }

    // Delete button
    if ( showDeleteButton ) {
        ofSetColor( 255, 255, 255, 50 );
        //ofNoFill();
        //ofCircle( delButtonPosX, delButtonPosY, delButtonRadius );
        //trashcan.setAnchorPoint( trashcan.getWidth() / 2, trashcan.getHeight() / 2 );
        trashcan.setAnchorPercent( 0.5, 0.5 );
        trashcan.draw( delButtonPosX, delButtonPosY, ofGetWidth() * 0.03, ofGetHeight() * 0.05 );
        ofSetColor( 255, 255, 255, 20 );
        hold.setAnchorPercent( 0.5, 0.5 );
        hold.draw( delButtonPosX, delButtonPosY + ( trashcan.getHeight() * 0.1 ), ofGetWidth() * 0.02, ofGetHeight() * 0.008 );

    }

    // Visual timer for delete file
    if ( delButtonIsPressed ) {
        ofSetColor( 255, 255, 255 );
        ofFill();
        ofRect( ofGetWidth() * 0.42, ofGetHeight() * 0.25, eraseRecFileTimer * (ofGetWidth() * 0.2 ), ofGetHeight() * 0.1 );
        ofNoFill();
        ofRect( ofGetWidth() * 0.42, ofGetHeight() * 0.25, ofGetWidth() * 0.2, ofGetHeight() * 0.1 );
    }
    
    
    // Meter
    /*if ( recButtonIsPressed ) {
        ofSetColor( 255, 0, 0 );
        ofRect( ofGetScreenWidth() * 0.25 , (ofGetScreenHeight() * 0.1), 10, -meter );
    }*/
    
}



void Recording::Exit() {
    
    //[soundFileURL release];
    
}


void Recording::RecordPressed() {
    
    muteAudioWhileRecording = true;
    
    readyToPlay = false;
    
    loadFileIsDone = false;
    
    recButtonColor = 255;
    
    //StopPressed();
    
    isRecording = true;
    
    [audioRecorder record];

    
}


void Recording::StopPressed() {
    
    if ( isRecording ) {
        
        [audioRecorder stop];
        
        muteAudioWhileRecording = false;
        
        readyToPlay = true;
        
        //waitForSaveFileTime = myTimer;
        
        //willWaitForSave = 1;
        
        recButtonColor = 100;
        
        willTakeRecording = false;
        
        showDeleteButton = true;
        
        saveFileIsDone = true;
        
    }
    
    isRecording = false;
}


// Init sound file on startup
NSString* Recording::getAudioFilePath() {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [searchPaths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/micRecording.wav", documentsPath];
    
    return fileName;
}


// Check if micRecording.wav is in the Documents directory
/*bool Recording::isFileInDir() {
    
    NSFileManager *myManager = [NSFileManager defaultManager];
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [searchPaths objectAtIndex:0];
    
    if([myManager fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"/micRecording.wav"]]){
        return true;
    } else {
        return false;
    }
}*/


// Setup sound file for recording
void Recording::SetupAudioFile() {

    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"micRecording.wav"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    

    
    audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
    
    audioRecorder.meteringEnabled = YES;
    
    myRecString = ofxNSStringToString( soundFilePath );
 
    
}





