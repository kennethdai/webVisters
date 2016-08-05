//
//  WVTableViewCell.m
//  WebVister
//
//  Created by KennethDai on 7/26/16.
//  Copyright © 2016 KennethDai. All rights reserved.
//

#import "WVTableViewCell.h"

@implementation WVTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.webView.scrollView setScrollEnabled:NO];
    self.webView.scalesPageToFit = YES;
    // Initialization code
    
    
}



- (IBAction)onDeleteBtnTapped:(UIButton *)sender {
}

- (IBAction)onEditBtnTapped:(UIButton *)sender {
}

- (void)loadViewWithUrl:(NSString *)urlStr
{
    if (!([urlStr rangeOfString:@"http://"].length && [urlStr rangeOfString:@"https://"].length))
    {
        urlStr = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    [self.webView loadRequest:urlRequest];
    self.urlLabel.text = urlStr;
    self.urlLabel2.text = urlStr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
