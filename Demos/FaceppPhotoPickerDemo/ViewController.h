//
//  ViewController.h
//  FaceppPhotoPickerDemo
//
//  Created by youmu on 12-12-5.
//  Copyright (c) 2012年 Megvii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceppAPI.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *button;
    UIImagePickerController *imagePicker;
}
-(IBAction)pickFromCameraButtonPressed:(id)sender;
-(IBAction)pickFromLibraryButtonPressed:(id)sender;
- (IBAction)payment:(id)sender;
- (IBAction)deldata:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *lblFaceId;

@property (retain, nonatomic) IBOutlet UILabel *txtInfo;
-(void) detectWithImage: (UIImage*) image;
@property (retain, nonatomic) IBOutlet UITextField *userName;
- (IBAction)add:(id)sender;

@end
