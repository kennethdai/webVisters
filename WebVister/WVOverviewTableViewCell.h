//
//  WVOverviewTableViewCell.h
//  WebVister
//
//  Created by KennethDai on 8/4/16.
//  Copyright © 2016 KennethDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WVOverviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)onDeleteBtnTapped:(UIButton *)sender;
- (IBAction)onEditBtnTapped:(UIButton *)sender;
- (void)loadViewWithUrl:(NSString *)urlStr;

@end
