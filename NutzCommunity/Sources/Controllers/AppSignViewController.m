//
//  AppSignViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/31.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "AppSignViewController.h"
#import "AppSignTableViewCell.h"
#import "UIPlaceHolderTextView.h"
#import "UITableView+FDTemplateLayoutCell.h"


//appsign key
#define kDiySignContent @"kDiySignContent"

static NSString *CellIdentifier = @"AppSignCell";
@interface AppSignViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{

}
@property (strong, nonatomic) UITableView  *tableView;
@property (strong, nonatomic) UITextField  *diySignText;
@end

@implementation AppSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置小尾巴";
    
}

- (void) loadView {
    [super loadView];
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame
                                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = KCOLOR_BG_COLOR;
    self.tableView.separatorColor  = [UIColor colorWithWhite:0.85 alpha:1.000];
    [self.tableView registerNib:[UINib nibWithNibName:@"AppSignTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 0){
        return 46;
    }
    return [tableView fd_heightForCellWithIdentifier:CellIdentifier cacheByIndexPath:indexPath configuration:^(UITableViewCell *cell) {
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        AppSignTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"AppSignTableViewCell" owner:self options:nil] lastObject];
        //使用自定义签名
        cell.sign.text = [User userSign];
        return cell;
    }
    UITableViewCell *cell    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:CellIdentifier];
    cell.textLabel.textColor = KCOLOR_MAIN_TEXT;
    cell.imageView.tintColor = KCOLOR_MAIN_BLUE;
    cell.textLabel.font      = [UIFont fontWithName:FONT_DEFAULE size:17];
    
    if(indexPath.row == 0){
        cell.textLabel.text = @" ";
        // 输入框
        [cell insertSubview:self.diySignText aboveSubview:cell.textLabel];
        [self.diySignText mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.textLabel);
            make.right.equalTo(cell.textLabel);
            make.height.equalTo(cell);
        }];
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"自定义签名";
        if([FIND_DEFAULTS(kAppSign) boolValue]){
            cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        }
    }else{
        cell.textLabel.text       = @"默认签名";
        if(!FIND_DEFAULTS(kAppSign) || ![FIND_DEFAULTS(kAppSign) boolValue]){
            cell.accessoryType    = UITableViewCellAccessoryCheckmark;
        }
    } 
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        if(indexPath.row == 1){//自定义
            if(![User saveUserSign:self.diySignText.text]){
                return;
            }
            SYNC_DEFAULTS(@(YES), kAppSign);
            [tableView reloadData];
        }else if(indexPath.row == 2){//默认
            SYNC_DEFAULTS(@(NO), kAppSign);
            [tableView reloadData];
        }
    }
}
#pragma mark textfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![User saveUserSign:self.diySignText.text]){
        return NO;
    }
    [textField resignFirstResponder];
    [self.tableView reloadData];
    return YES;
}

#pragma mark fixed RESideMenu 滑动隐藏状态栏的问题
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

#pragma mark Getter
- (UITextField*)diySignText {
    if(!_diySignText){
        _diySignText               = [UITextField new];
        _diySignText.placeholder   = @"请输入自定义签名,15字以内~";
        _diySignText.textColor     = KCOLOR_MAIN_BLUE;
        _diySignText.text          = FIND_DEFAULTS(kAppSignContent);
        _diySignText.returnKeyType = UIReturnKeyDone;
        _diySignText.delegate      = self;
    }
    return _diySignText;
}

@end
