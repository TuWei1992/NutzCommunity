//
//  AKScanCodeViewController.m
//  AKScanCodeViewController
//
//  Created by TuWei on 15/12/27.
//
#import <AVFoundation/AVFoundation.h>
#import "QRCodeScanViewController.h"

//
#define kQRAreaWidth 260.0f
#define kButtonWidth 37.0f

@interface QRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate> {
    BOOL _isAnimating;
}

@property (strong,nonatomic) AVCaptureDevice * device;
@property (strong,nonatomic) AVCaptureDeviceInput * input;
@property (strong,nonatomic) AVCaptureMetadataOutput * output;
@property (strong,nonatomic) AVCaptureSession * session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * preview;
@property (strong,nonatomic) AVAudioPlayer *player;
@property (nonatomic,retain) UIImageView * line;

@end

@implementation QRCodeScanViewController{
    // nav bar push前是不是隐藏的
    BOOL navBarHide;
    // 闪光标志
    BOOL torchIsOn;
    // 是不是从picker返回的, 如果是不记录导航栏的隐藏状态
    BOOL dismissFromPicker;
}

+ (instancetype)controllerWithShowType:(ShowType)showType callback:(void(^)(NSString *)) callbackBlock{
    QRCodeScanViewController *ctrl = [QRCodeScanViewController new];
    ctrl.blockEndScanWithText = callbackBlock;
    ctrl.showType = showType;
    return ctrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码扫描";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupButtons];
    [self setupUI];
    
    // 声音
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"sound" ofType:@"caf"];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    self.player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [self.player prepareToPlay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 是否初始化了
    if (_device != nil) {
        [self beginReading];
    } else {
        [self setupCamera];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    
    // 已经初始化, 开始读取
    if (_device != nil) {
        [self beginReading];
    }
    
    // 记录导航栏隐藏状态
    if(!dismissFromPicker){// 如果不是从imagepicker 回来的那么才记录状态
        navBarHide = self.navigationController.navigationBarHidden;
    }else{
        dismissFromPicker = NO;
    }
    [self.navigationController setNavigationBarHidden:YES];
   
    // 添加进入前后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(beginReading)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endReading)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self endReading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

#pragma mark -
#pragma mark ---------SetUP
- (void)setupButtons {
    // 顶部三个按钮
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *photo = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *flash = [UIButton buttonWithType:UIButtonTypeCustom];
    int padding = kButtonWidth/2;
    back.frame = CGRectMake(padding, padding, kButtonWidth, kButtonWidth);
    photo.frame = CGRectMake(self.view.center.x-padding, padding, kButtonWidth, kButtonWidth);
    flash.frame = CGRectMake(self.view.frame.size.width-kButtonWidth-padding*1.5, padding, kButtonWidth, kButtonWidth);
    
    [back setImage:[UIImage imageNamed:@"ocrBack"] forState:UIControlStateNormal];
    [photo setImage:[UIImage imageNamed:@"ocr_albums"] forState:UIControlStateNormal];
    [flash setImage:[UIImage imageNamed:@"ocr_flash-off"] forState:UIControlStateNormal];
    
    [back addTarget:self action:@selector(actionPopBack) forControlEvents:UIControlEventTouchUpInside];
    [photo addTarget:self action:@selector(openAlbum) forControlEvents:UIControlEventTouchUpInside];
    [flash addTarget:self action:@selector(turnTorchOn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:back];
    [self.view addSubview:photo];
    [self.view addSubview:flash];
    
}
- (void)setupUI {
    
    //框框之外的黑色蒙版
    UIColor *cColor =[[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    //使用MaskLayer作为蒙版
    UIView *transView = [[UIView alloc] initWithFrame:self.view.frame];
    transView.backgroundColor = cColor;
    transView.userInteractionEnabled = NO;
    [self.view addSubview:transView];
    
    //ImageView Frame, 确保在屏幕中心
    CGRect imageFrame = CGRectMake( self.view.frame.size.width/2 - kQRAreaWidth/2, self.view.center.y - kQRAreaWidth/2, kQRAreaWidth, kQRAreaWidth);

    //图片到空白区域的inset
    CGRect innerFrame = CGRectInset(imageFrame, 0, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIBezierPath *imageViewPath = [[UIBezierPath bezierPathWithRoundedRect:innerFrame cornerRadius:0] bezierPathByReversingPath];
    [path appendPath:imageViewPath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    transView.layer.mask = maskLayer;
    
    //框框的各个点的位置
    int squareWidth = 19;
    int leftBase    = imageFrame.origin.x;
    int topBase     = imageFrame.origin.y;
    int rightBase   = leftBase + imageFrame.size.width - squareWidth + 1;
    int bottomBase  = topBase + imageFrame.size.height - squareWidth + 3;
    
    UIColor *tint = [UIColor colorWithRed:0.286 green:0.593 blue:0.879 alpha:1.000];
    
    //框框4个角 the frame of the square
    UIImageView * lt = [[UIImageView alloc] initWithFrame:CGRectMake(leftBase, topBase, squareWidth, squareWidth)];
    UIImage *lti = [UIImage imageNamed:@"scan_1"];
    lt.image = [lti imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    lt.tintColor = tint;
    UIImageView * rt = [[UIImageView alloc] initWithFrame:CGRectMake(rightBase, topBase, squareWidth, squareWidth)];
    UIImage *rti = [UIImage imageNamed:@"scan_2"];
    rt.image = [rti imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    rt.tintColor = tint;
    UIImageView * lb = [[UIImageView alloc] initWithFrame:CGRectMake(leftBase, bottomBase, squareWidth, squareWidth)];
    UIImage *lbi = [UIImage imageNamed:@"scan_3"];
    lb.image = [lbi imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    lb.tintColor = tint;
    UIImageView * rb = [[UIImageView alloc] initWithFrame:CGRectMake(rightBase, bottomBase, squareWidth, squareWidth)];
    UIImage *rbi = [UIImage imageNamed:@"scan_4"];
    rb.image = [rbi imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    rb.tintColor = tint;
    
    [self.view addSubview:lt];
    [self.view addSubview:rt];
    [self.view addSubview:lb];
    [self.view addSubview:rb];
    
    // 文字提示
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor colorWithWhite:1.000 alpha:0.80];
    labIntroudction.textAlignment  = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont systemFontOfSize:14];
    labIntroudction.text=@"将二维码放入框内，即可自动扫描";
    labIntroudction.frame = CGRectMake(leftBase, bottomBase + 25, kQRAreaWidth, 25);
    [self.view addSubview:labIntroudction];
    
    //扫描的横线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(leftBase, topBase - kQRAreaWidth, kQRAreaWidth, kQRAreaWidth)];
    _line.image = [UIImage imageNamed:@"scan_net"];
    _line.alpha = 0;
    [self.view addSubview:_line];
}

- (void)setupCamera {
    // 判断权限
    if(![self canUseCamera]){
        [self actionPopBack];
        return;
    }
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描兴趣点，坐标系远点在右上角，长宽互换，按照比例  参考文章 http://blog.csdn.net/lc_obj/article/details/41549469
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    
    //ImageView的frame
    CGRect trueFrame = CGRectMake( self.view.frame.size.width/2 - kQRAreaWidth/2, self.view.center.y - kQRAreaWidth/2, kQRAreaWidth, kQRAreaWidth);
    CGRect insets =CGRectMake(trueFrame.origin.y/viewHeight,
                              trueFrame.origin.x/viewWidth,
                              trueFrame.size.height/viewHeight,
                              trueFrame.size.width/viewWidth);
    [_output setRectOfInterest: insets];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    CGRect bounds = self.view.frame;
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self startAnimation];
    [_session startRunning];
}

#pragma mark -
#pragma mark ---------SessionControl
// 启动session
- (void)beginReading{
    [self startAnimation];
    if (!self.session.running) {
        [self.session startRunning];
    }
}

// 关闭session
- (void)endReading{
    [self stopAnimation];
    if (self.session.running) {
        [self.session stopRunning];
    }
} 

#pragma mark -
#pragma mark ---------AnimationControl
- (void)startAnimation {
    
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    
    //从上到下的动画
    CABasicAnimation *upDonwn = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    upDonwn.duration = 1.5f;
    upDonwn.repeatCount = 0;
    upDonwn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    upDonwn.removedOnCompletion = NO;
    upDonwn.fillMode = kCAFillModeForwards;
    upDonwn.toValue = @(kQRAreaWidth);
    
    //透明度动画
    CABasicAnimation *transAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    transAni.duration = 1.f;
    transAni.repeatCount = 0;
    transAni.removedOnCompletion = NO;
    transAni.fillMode = kCAFillModeForwards;
    transAni.fromValue =  @(0.0f);
    transAni.toValue = @(0.9f);
    
    //隐藏动画
    CABasicAnimation *disappearAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    disappearAni.duration = 0.3f;
    disappearAni.beginTime = 1.5;
    disappearAni.repeatCount = 0;
    disappearAni.removedOnCompletion = NO;
    disappearAni.fillMode = kCAFillModeForwards;
    disappearAni.toValue = @(0.0f);
    
    CAAnimationGroup *aniGroup = [CAAnimationGroup animation];
    [aniGroup setAnimations:@[upDonwn, transAni, disappearAni]];
    aniGroup.duration = 1.8;
    aniGroup.repeatCount = MAXFLOAT;
    [self.line.layer addAnimation:aniGroup forKey:@"groupAnimation"];
    
}

- (void)stopAnimation {
    if (_isAnimating == NO) {
        return;
    }
    
    _isAnimating = NO;
    [self.line.layer removeAllAnimations];
    self.line.layer.transform = CATransform3DIdentity;
}


#pragma mark -
#pragma mark --------- <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    [self endReading];
    
    AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
    NSString *codeStr= nil;
    if ([metadata respondsToSelector:@selector(stringValue)]) {
        codeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
    }
    
    if (codeStr != nil) {
        [self.player play];
        if (self.blockEndScanWithText) {
            self.blockEndScanWithText(codeStr);
            _blockEndScanWithText = nil;
        }
        [self actionPopBack];
        return;
    }
    
    NSLog(@"无法识别~");
}

#pragma mark -
#pragma mark --------- <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        //当选择的类型是图片
        if ([type isEqualToString:@"public.image"]){
            //先把图片转成NSData
            UIImage* originImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            CIContext *context = [CIContext contextWithOptions:nil];
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
            CIImage *image = [CIImage imageWithCGImage:originImage.CGImage];
            NSArray *features = [detector featuresInImage:image];
            CIQRCodeFeature *feature = [features firstObject];
            
            NSString *result = feature.messageString;
            if ([result isEqualToString:@""] || result.length == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未发现二维码或无法识别" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                [self.player play];
                if (self.blockEndScanWithText) {
                    self.blockEndScanWithText(result);
                    _blockEndScanWithText = nil;
                }
                [self actionPopBack];
            }
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请选择二维码图片进行识别" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark ---------Private Methods
- (void)actionPopBack {
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:NO];
    }
    if(self.showType == ShowTypePresent){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(BOOL)canUseCamera {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请进入 \"设置 - 隐私 - 相机\" 中允许应用访问相机。" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

- (void)openAlbum{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此功能仅支持iOS 8及以上系统" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    // 将从相册选取返回
    dismissFromPicker = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //跳转代码
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = (id)self;
        picker.view.backgroundColor = [UIColor whiteColor];
        //设置选择后的图片可被编辑
        picker.allowsEditing = NO;
        
        [self presentViewController:picker animated:YES completion:nil];
    });
}

// 开启闪光灯
- (void)turnTorchOn:(UIButton *)sender{
    if(_device){
        if ([_device hasTorch] && [_device hasFlash]){
            
            [_device lockForConfiguration:nil];
            if (!torchIsOn) {
                [_device setTorchMode:AVCaptureTorchModeOn];
                [_device setFlashMode:AVCaptureFlashModeOn];
                [sender setImage:[UIImage imageNamed:@"ocr_flash-on"] forState:UIControlStateNormal];
                torchIsOn = YES;
            } else {
                [_device setTorchMode:AVCaptureTorchModeOff];
                [_device setFlashMode:AVCaptureFlashModeOff];
                [sender setImage:[UIImage imageNamed:@"ocr_flash-off"] forState:UIControlStateNormal];
                torchIsOn = NO;
            }
            [_device unlockForConfiguration];
        }
    }
   
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
