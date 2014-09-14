//
//  RootViewController.h
//  StickyHeaderView
//
//  Created by Mitul Bhadesiya on 29/08/14.
//  Copyright (c) 2014 tttt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RootViewController : UIViewController
{
    int numberOfFile;
    UIImage *myImage;
    CALayer *aLayer;
    CALayer *parentLayer;
    CALayer *videoLayer;
    
    IBOutlet UILabel *lblDisp;
    
}

@property(nonatomic,strong)AVAsset* firstAsset;
@property(nonatomic,strong)AVAsset* midAsset;
@property(nonatomic,strong)AVAsset* lastAsset;



@end
