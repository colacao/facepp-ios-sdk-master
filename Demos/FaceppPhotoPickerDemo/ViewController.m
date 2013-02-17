//
//  ViewController.m
//  FaceppPhotoPickerDemo
//
//  Created by youmu on 12-12-5.
//  Copyright (c) 2012年 Megvii. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import <sqlite3.h>

@implementation ViewController{
    int type;
    NSUserDefaults *saveDefaults;
    NSString *my;
    NSString *you;
    NSString *female;
    NSMutableArray *_objects;

}
static UIView *FindFirstResponder(UIView *view) {
	if (view.isFirstResponder) {
		return view;
	}
	UIView *ret = nil;
	for (UIView *subview in view.subviews) {
		if((ret = FindFirstResponder(subview))) {
			break;
		}
	}
	return ret;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    saveDefaults = [NSUserDefaults standardUserDefaults];
     my = [saveDefaults objectForKey:@ "face_id"];
    NSLog(@"我是%@",my);
//NSLog(@"dbPath====%@",dbPath);
	// Do any additional setup after loading the view, typically from a nib.
    imagePicker = [[UIImagePickerController alloc] init];

    // initialize
    NSString *API_KEY = @"f1e05e95252b48b44d8e1a91b0a47f7f";
    NSString *API_SECRET = @"rjXOf83on_nwjRiSRXd386699QJViKoF";

    [FaceppAPI initWithApiKey:API_KEY andApiSecret:API_SECRET];
    
    // turn on the debug mode
    [FaceppAPI setDebugMode:TRUE];
    
    
    
    UITapGestureRecognizer *AUTO_HIDE_KEYBOARD_gr = 
	[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(method)]; 
    AUTO_HIDE_KEYBOARD_gr.cancelsTouchesInView = NO; 
    [self.view addGestureRecognizer:AUTO_HIDE_KEYBOARD_gr];
}
- (void)method { 
	UIView *responder = FindFirstResponder(self.view);
	if ([responder isKindOfClass:[UITextField class]]) { 
		[responder resignFirstResponder]; 
	} 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pickFromCameraButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        type = 0;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice=1;
        [self presentModalViewController:imagePicker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to camera"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
}

-(IBAction)pickFromLibraryButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imagePicker animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to access photo library"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)payment:(id)sender {
    type=1;
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)deldata:(id)sender {
    sqlite3 *dbHandle;
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/face.db",NSHomeDirectory()];

    if (sqlite3_open([dbPath UTF8String], &dbHandle)==SQLITE_OK) {
        NSLog(@"打开数据库成功!");
        char *errorMsg;
        if (sqlite3_exec(dbHandle, "drop table myface", NULL, NULL, &errorMsg)!=SQLITE_OK) {
            NSLog(@"操作失败!");
        }
        NSLog(@"清空数据库成功!");

        sqlite3_close(dbHandle);
    }
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// Use facepp SDK to detect faces 
-(void) detectWithImage: (UIImage*) image {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    FaceppResult *result = [[FaceppAPI detection] detectWithURL:nil imageData:UIImageJPEGRepresentation(image, 1)];
    
    if (result.success) {
        female = [result content][@"face"][0][@"attribute"][@"gender"][@"value"];

        if(type==0){
            
            [saveDefaults setObject:[result content][@"face"][0][@"face_id"] forKey:@ "face_id" ];
            my = [saveDefaults objectForKey:@ "face_id"];
            self.lblFaceId.text=my;

        }else{
            my = [saveDefaults objectForKey:@ "face_id"];
            you = [result content][@"face"][0][@"face_id"];
            self.lblFaceId.text = you;
            NSLog(@"我是:%@，他是:%@",my,you);
            [self ComparisonByFace:you];
            
//            FaceppResult *cpresult = [[FaceppAPI recognition] compareWithFaceId1:my andId2:you];
//            UIAlertView *alert = [[UIAlertView alloc]
//                                  initWithTitle:[NSString stringWithFormat:@"相似度: %@", [cpresult content][@"similarity"]]
//                                  message:@""
//                                  delegate:nil
//                                  cancelButtonTitle:@"OK!"
//                                  otherButtonTitles:nil];
//            [alert show];
//            [alert release];
            
            
        }
        double image_width = [[result content][@"img_width"] doubleValue] *0.01f;
        double image_height = [[result content][@"img_height"] doubleValue] * 0.01f;

        UIGraphicsBeginImageContext(image.size);
        [image drawAtPoint:CGPointZero];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, image_width * 0.7f);
        
        // draw rectangle in the image
        int face_count = [[result content][@"face"] count];
        for (int i=0; i<face_count; i++) {
            double width = [[result content][@"face"][i][@"width"] doubleValue];
            double height = [[result content][@"face"][i][@"height"] doubleValue];
            CGRect rect = CGRectMake(([[result content][@"face"][i][@"center"][@"x"] doubleValue] - width/2) * image_width,
                                     ([[result content][@"face"][i][@"center"][@"y"] doubleValue] - height/2) * image_height,
                                     width * image_width,
                                     height * image_height);
            CGContextStrokeRect(context, rect);
        }
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        float scale = 1.0f;
        scale = MIN(scale, 280.0f/newImage.size.width);
        scale = MIN(scale, 257.0f/newImage.size.height);
        [imageView setFrame:CGRectMake(imageView.frame.origin.x,
                                       imageView.frame.origin.y,
                                       newImage.size.width * scale,
                                       newImage.size.height * scale)];
        [imageView setImage:newImage];
    } else {
        // some errors occurred
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"error message: %@", [result error].message]
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [image release];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [pool release];
}
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    UIImage *imageToDisplay;
    if(type!=0){
        UIImage *cimg = [self scaleImage:sourceImage toScale:0.4f];
    
    imageToDisplay= [self fixOrientation:cimg];
    }else{
        imageToDisplay = [self fixOrientation:sourceImage];

    }
    
    NSLog(@"perform detection in background thread");
    [self performSelectorInBackground:@selector(detectWithImage:) withObject:[imageToDisplay retain]];
    
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

-(void) dealloc {
    [imagePicker release];
    [_userName release];
    [_txtInfo release];
    [_lblFaceId release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUserName:nil];
    [super viewDidUnload];
}
-(void)ComparisonByFace:(NSString *)face_id{
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/face.db",NSHomeDirectory()];
    NSInteger imax = 0;
    NSString *username=@"";
    NSLog(@"比较face_id=%@，%@",face_id,dbPath);
    sqlite3 *dbHandle;
    if (sqlite3_open([dbPath UTF8String], &dbHandle)==SQLITE_OK) {
        char *errorMsg;
        if (sqlite3_exec(dbHandle, "create table if not exists myface(face_id,user_name);", NULL, NULL, &errorMsg)!=SQLITE_OK) {
            NSLog(@"操作失败!");
        }
        const char *selectSql="select * from myface";
        sqlite3_stmt *statement1 = NULL;
        if (sqlite3_prepare_v2(dbHandle, selectSql, -1, &statement1, nil)==SQLITE_OK) {
            NSLog(@"select ok.");
        }
        int icount=0;
        while (sqlite3_step(statement1)==SQLITE_ROW) {
            NSLog(@"---------------------------------------------------------");

            NSString *strid=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement1, 1) encoding:NSUTF8StringEncoding];
             NSString *strname=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement1, 0) encoding:NSUTF8StringEncoding];
            NSLog(@"ID==========================%@,%@",strid,strname);
            
            FaceppResult *cpresult = [[FaceppAPI recognition] compareWithFaceId1:face_id andId2:strid];
            NSInteger i=[[cpresult content][@"similarity"] integerValue];
            if(i>imax){
                imax = i;
                username = strname;
            }

            
            if(_objects==nil){
                _objects = [[NSMutableArray alloc] init];
            }
            [_objects addObject:strid];
            icount++;

        }
        
        sqlite3_finalize(statement1);
        sqlite3_close(dbHandle);
        
    }
    if(imax>60){
    self.txtInfo.text=[NSString stringWithFormat:@"相似度: %@", [username stringByAppendingString:[NSString stringWithFormat: @"%d", imax]]];
    }else{
        if([female isEqual:@"Female"]){
            self.txtInfo.text=@"没人与这个女的相似";
        }else{
            self.txtInfo.text=@"没人与这个男的相似";

        }
    }
   // NSString *str = [_objects componentsJoinedByString:@","];
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle:[NSString stringWithFormat:@"相似度: %@", [username stringByAppendingString:[NSString stringWithFormat: @"%d", imax]]]
//                          message:@""
//                          delegate:nil
//                          cancelButtonTitle:@"OK!"
//                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];

    
       
}
- (IBAction)add:(id)sender {
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/face.db",NSHomeDirectory()];

     NSLog(@"添回数据!%@",dbPath);
    sqlite3 *dbHandle;
    if (sqlite3_open([dbPath UTF8String], &dbHandle)==SQLITE_OK) {
        NSLog(@"打开数据库成功!");
        char *errorMsg;
        if (sqlite3_exec(dbHandle, "create table if not exists myface(face_id,user_name);", NULL, NULL, &errorMsg)!=SQLITE_OK) {
            NSLog(@"操作失败!");
        }
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(dbHandle, [@"insert into myface(face_id,user_name) values(?,?);" UTF8String], -1, &statement, NULL)!=SQLITE_OK) {
            return;
        }
 
        NSLog(@"新增%@,%@",self.userName.text,you);
        const char *text1=[self.userName.text cStringUsingEncoding:NSUTF8StringEncoding];
        const char *text2=[self.lblFaceId.text cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_bind_text(statement, 1, text1, strlen(text1), SQLITE_STATIC);
        sqlite3_bind_text(statement, 2, text2, strlen(text2), SQLITE_STATIC);
        if (sqlite3_step(statement)!=SQLITE_DONE) {
            sqlite3_finalize(statement);
            return;
        }
        sqlite3_finalize(statement);
        sqlite3_close(dbHandle);    
    }

}
@end
