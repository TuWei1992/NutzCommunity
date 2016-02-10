//  Created by TuWei on 15/12/27.
/*
 修改自github
 */

#import <UIKit/UIKit.h>

//VC弹出类型
typedef enum{
    ShowTypePush=0,
    ShowTypePresent
}ShowType;

@interface QRCodeScanViewController : UIViewController

+ (instancetype)controllerWithShowType:(ShowType)showType callback:(void(^)(NSString *)) callbackBlock;

@property (nonatomic, assign) ShowType showType;
/** 扫描结束回调  Block called when get result string from code **/
@property (nonatomic, copy) void(^blockEndScanWithText)(NSString *resultText);

@end
