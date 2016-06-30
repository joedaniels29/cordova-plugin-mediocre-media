#import "Media.h"

@implementation JDMediaPlayer
+ (instancetype)instance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });

    // returns the same object each time
    return _sharedObject;
}

- (void)play {[self.player play];}

- (void)pause {[[self player] pause];}

- (NSURL *)fileUrl {
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory, NSUserDomainMask, YES)[0]
            stringByAppendingPathComponent:@"sound.caf"]];
}

- (void)record {
    // delete old
    NSError *err = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.fileUrl path]])
        [[NSFileManager defaultManager] removeItemAtPath:[self.fileUrl path]
                                                   error:&err];
    if (err)
        return NSLog(@"File Manager: %@ %ld %@", [err domain], (long) [err code],
                [[err userInfo] description]);
    err = nil;

    // Make new audio
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if (err)
        return NSLog(@"audioSession: %@ %d %@", [err domain], [err code],
                [[err userInfo] description]);
    err = nil;

    [audioSession setActive:YES error:&err];
    if (err)
        return NSLog(@"audioSession: %@ %d %@", [err domain], [err code],
                [[err userInfo] description]);
    err = nil;

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];

    recordSetting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
    recordSetting[AVSampleRateKey] = @44100.0F;
    recordSetting[AVNumberOfChannelsKey] = @2;

    recordSetting[AVLinearPCMBitDepthKey] = @16;
    recordSetting[AVLinearPCMIsBigEndianKey] = @NO;
    recordSetting[AVLinearPCMIsFloatKey] = @NO;

    NSURL *url = self.fileUrl;
    err = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url
                                                settings:recordSetting
                                                   error:&err];
    if (!self.recorder)
        return [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"recorder: %@ %d %@", [err domain], [err code],
                    [[err userInfo] description]);
            UIAlertView *alert =
                    [[UIAlertView alloc] initWithTitle:@"Warning"
                                               message:[err localizedDescription]
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }];

    // prepare to record
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];

    if (![audioSession inputIsAvailable])
        return [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIAlertView *cantRecordAlert = [[UIAlertView alloc]
                    initWithTitle:@"Warning"
                          message:@"Audio input hardware not available"
                         delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
            [cantRecordAlert show];
        }];

    // start recording
    [self.recorder recordForDuration:(NSTimeInterval) 10];
}

- (void)stopRecording {
    [self.recorder stop];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];

    // create player
    NSError *err = nil;
    self.player =
            [[AVAudioPlayer alloc] initWithContentsOfURL:self.fileUrl error:nil];
    if (err)
        return NSLog(@"Audio Player: %@ %ld %@", [err domain], (long) [err code],
                [[err userInfo] description]);
    self.player.delegate = self;
    [self.player prepareToPlay];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder
                           successfully:(BOOL)flag {NSLog(@"Recorded!!");}

- (void)clear {[[self recorder] deleteRecording];}
@end

@implementation JDMedia

- (void)microphone:(CDVInvokedUrlCommand *)command {

    NSArray *version =
            [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

    if ([version[0] intValue] < 7) {
        // iOS versions before 7 need no permission to record
        [self.commandDelegate
                sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                     messageAsBool:true]
                      callbackId:[command callbackId]];
    } else {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            [self.commandDelegate
                    sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                         messageAsBool:granted]
                          callbackId:[command callbackId]];
        }];
    }
}

- (void)play:(CDVInvokedUrlCommand *)command {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [[JDMediaPlayer instance] play];

        [self.commandDelegate
                sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                     messageAsBool:true]
                      callbackId:[command callbackId]];
    }];
}

- (void)pause:(CDVInvokedUrlCommand *)command {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [[JDMediaPlayer instance] pause];

        [self.commandDelegate
                sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                     messageAsBool:true]
                      callbackId:[command callbackId]];
    }];
}

- (void)record:(CDVInvokedUrlCommand *)command {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [[JDMediaPlayer instance] record];

        [self.commandDelegate
                sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                     messageAsBool:true]
                      callbackId:[command callbackId]];
    }];
}

- (void)stopRecording:(CDVInvokedUrlCommand *)command {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [[JDMediaPlayer instance] stopRecording];

        [self.commandDelegate
                sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                     messageAsBool:true]
                      callbackId:[command callbackId]];
    }];
}

- (void)clear:(CDVInvokedUrlCommand *)command {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [[JDMediaPlayer instance] clear];

        [self.commandDelegate
                sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                     messageAsBool:true]
                      callbackId:[command callbackId]];
    }];
}

@end
