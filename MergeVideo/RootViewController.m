//
//  RootViewController.m
//  StickyHeaderView
//
//  Created by Mitul Bhadesiya on 29/08/14.
//  Copyright (c) 2014 tttt. All rights reserved.
//

#import "RootViewController.h"


@interface RootViewController ()

@end

@implementation RootViewController

@synthesize firstAsset;
@synthesize midAsset;
@synthesize lastAsset;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"MITS";

    /*
    NSString *midVideo = [[NSBundle mainBundle] pathForResource:@"MidVid" ofType:@"mp4"];
    NSString *startVid = [[NSBundle mainBundle] pathForResource:@"StartVid" ofType:@"mp4"];
    NSString *stopVid = [[NSBundle mainBundle] pathForResource:@"StopVid" ofType:@"mp4"];
     */
    
    
    NSString *midVideo = [[NSBundle mainBundle] pathForResource:@"vid1" ofType:@"mp4"];
    NSString *startVid = [[NSBundle mainBundle] pathForResource:@"vid2" ofType:@"mp4"];
    NSString *stopVid = [[NSBundle mainBundle] pathForResource:@"vid3" ofType:@"mp4"];

    numberOfFile = 3; // Number Of Video You want to merge
    
    // Create First Asset For Video 1
    NSURL *firstUrl = [NSURL fileURLWithPath:startVid];
    firstAsset = [AVAsset assetWithURL:firstUrl];
    
    NSURL *midUrl = [NSURL fileURLWithPath:midVideo];
    midAsset = [AVAsset assetWithURL:midUrl];

    NSURL *lastUrl = [NSURL fileURLWithPath:stopVid];
    lastAsset = [AVAsset assetWithURL:lastUrl];
    
    [self MergeAndSave];
}

-(AVAsset *)currentAsset:(int)num
{
    if(num == 0)
    {
        return firstAsset;
    }
    else if(num == 1){
        return midAsset;
    }
    else if(num == 2){
        
        return lastAsset;
    }
    return nil;
}




- (void)MergeAndSave
{
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    NSMutableArray *arrayInstruction = [[NSMutableArray alloc] init];
    
    AVMutableVideoCompositionInstruction * MainInstruction =
    [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableCompositionTrack *audioTrack;
    
    audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                             preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    CMTime duration = kCMTimeZero;
    for(int i=0;i< numberOfFile;i++)
    {
        AVAsset *currentAsset = [self currentAsset:i]; // i take the for loop for geting the asset
        /* Current Asset is the asset of the video From the Url Using AVAsset */
        
        
        AVMutableCompositionTrack *currentTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [currentTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration) ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:duration error:nil];
        
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration) ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:duration error:nil];
        
        AVMutableVideoCompositionLayerInstruction *currentAssetLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:currentTrack];
        AVAssetTrack *currentAssetTrack = [[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation currentAssetOrientation  = UIImageOrientationUp;
        BOOL  isCurrentAssetPortrait  = NO;
        CGAffineTransform currentTransform = currentAssetTrack.preferredTransform;
        
        if(currentTransform.a == 0 && currentTransform.b == 1.0 && currentTransform.c == -1.0 && currentTransform.d == 0)  {currentAssetOrientation= UIImageOrientationRight; isCurrentAssetPortrait = YES;}
        if(currentTransform.a == 0 && currentTransform.b == -1.0 && currentTransform.c == 1.0 && currentTransform.d == 0)  {currentAssetOrientation =  UIImageOrientationLeft; isCurrentAssetPortrait = YES;}
        if(currentTransform.a == 1.0 && currentTransform.b == 0 && currentTransform.c == 0 && currentTransform.d == 1.0)   {currentAssetOrientation =  UIImageOrientationUp;}
        if(currentTransform.a == -1.0 && currentTransform.b == 0 && currentTransform.c == 0 && currentTransform.d == -1.0) {currentAssetOrientation = UIImageOrientationDown;}
        
        CGFloat FirstAssetScaleToFitRatio = 640.0/640.0;
        if(isCurrentAssetPortrait){
            FirstAssetScaleToFitRatio = 640.0/640.0;
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [currentAssetLayerInstruction setTransform:CGAffineTransformConcat(currentAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:duration];
        }else{
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [currentAssetLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(currentAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 0)) atTime:duration];
        }
        
        duration=CMTimeAdd(duration, currentAsset.duration);
        
        [currentAssetLayerInstruction setOpacity:0.0 atTime:duration];
        [arrayInstruction addObject:currentAssetLayerInstruction];
        
        NSLog(@"%lld", duration.value/duration.timescale);
        

        myImage = [UIImage imageNamed:@"mits@2x.png"];
        aLayer  = [CALayer layer];
        //[aLayer retain];
        aLayer.contents = (id)myImage.CGImage;
        aLayer.frame = CGRectMake(640-100, 100, 20, 20);
        aLayer.opacity = 1;
        
        parentLayer = [CALayer layer];
        videoLayer  = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, 640,640);
        videoLayer.frame = CGRectMake(0, 0, 640, 640);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        
    }
    
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
    MainInstruction.layerInstructions = arrayInstruction;
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    MainCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640.0, 640.0);
    
    NSString *myPathDocs =  [[self applicationCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo%-dtemp.mp4",arc4random() % 10000]];
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.videoComposition = MainCompositionInst;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch (exporter.status)
         {
             case AVAssetExportSessionStatusCompleted:
              {
                 NSURL *outputURL = exporter.outputURL;
                 
                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                 if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
                     
                     ALAssetsLibrary* library = [[ALAssetsLibrary alloc]init];
                     [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error)
                      {
                          NSLog(@"ASSET URL %@",assetURL);
                          if (error)
                          {
                              NSLog(@"EROR %@ ", error);
                          }else{
                              NSLog(@"VIDEO SAVED ");
                          }
                          
                      }];
                     
                     NSLog(@"Video Merge SuccessFullt");
                     lblDisp.text = @"3 Videos Mearge Sucessfully Completed check in Doc Directory";
                 }
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@", exporter.error.description);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@", exporter.error);
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"Exporting!");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"Waiting");
                 break;
             default:
                 break;
         }
     }];
}

-(void)savefinalVideoFileToDocuments:(NSURL *)url
{
    NSString *storePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:@"FinalVideo"];
    storePath = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"mergedvideo"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:storePath] == YES) {
        NSLog(@"removeItemAtPath >>>>>>>>>>>>>>>>>> saveVideoFileToDocuments 1 :%@", storePath);
        [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
    }
    
    NSError * error = nil;
    if (url == nil) {
        return;
    }
    
    [[NSFileManager defaultManager] copyItemAtURL:url
                                            toURL:[NSURL fileURLWithPath:storePath]
                                            error:&error];
    
    if ( error ) {
        NSLog(@"%@", error);
        NSLog(@"removeItemAtPath >>>>>>>>>>>>>>>>>> saveVideoFileToDocuments 2 :%@", storePath);
        [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
        return;
    }
    //[objEditView thumbnailFromVideoAtURL:url];
    NSData * movieData = [NSData dataWithContentsOfURL:url];
    [movieData writeToFile:storePath atomically:YES];
}

-(NSString *)applicationCacheDirectory
{
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return basePath;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
