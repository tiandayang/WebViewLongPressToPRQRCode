//
//  BaseWebViewController.m
//  WebViewLongPressToPRQRCode
//
//  Created by 田向阳 on 2017/11/6.
//  Copyright © 2017年 田向阳. All rights reserved.
//

#import "BaseWebViewController.h"

@interface BaseWebViewController ()<UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation BaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [webView loadRequest:request];
    webView.delegate = self;
    webView.userInteractionEnabled = YES;
    //添加长安手势
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress:)];
    [webView addGestureRecognizer:longpress];
    longpress.delegate = self;
    self.webView = webView;
}
#pragma mark - UIWebviewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return  YES;
}

#pragma mark - recognizer
- (void)longpress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchPoint = [recognizer locationInView:self.webView];
            // 使用js获取点击位置存在的图片链接
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
        NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlToSave]];
        UIImage* image = [UIImage imageWithData:data];
        if (image == nil) {
            return;
        }
        [self showAlert:image];
    }
}

- (void)showAlert:(UIImage *)image
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"CIDetectorAccuracy", @"CIDetectorAccuracyHigh",nil];
    CIDetector *detector = nil;
    detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                  context:nil
                                  options:options];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    UIAlertAction *judgeCode = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scannedResult]]){
            NSLog(@"scannedResult = %@", scannedResult);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scannedResult]];
        }else{
            NSLog(@"无法识别的网址");
        }
    }];
    
    UIAlertAction *saveImage = [UIAlertAction actionWithTitle:@"保存图片到手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    
    UIAlertAction *cancell = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    if (features.count >= 1) {
        [alertController addAction:judgeCode];
    }
    
    [alertController addAction:saveImage];
    [alertController addAction:cancell];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    if (!error) {
        NSLog(@"保存成功");
    }
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
