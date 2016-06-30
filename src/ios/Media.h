#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
 #import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface JDMediaPlayer
    : NSObject <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property(strong) AVAudioPlayer *player;
@property(strong) AVAudioRecorder *recorder;

+ (instancetype)instance;

- (void)play;
- (void)pause;
- (void)record;
- (void)stopRecording;
- (void)clear;
@end

@interface JDMedia : CDVPlugin
- (void)play;
- (void)pause;
- (void)record;
- (void)stopRecording;
- (void)clear;
@end
