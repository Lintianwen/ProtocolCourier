//
//  GYScrollViewDelegate.m
//  ProtocolCourier
//
//  Created by GuYi on 2017/5/14.
//
//

#import "GYScrollViewDelegate.h"

@implementation GYScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.label.text = [NSString stringWithFormat:@"%.2f", scrollView.contentOffset.y];
}

@end
