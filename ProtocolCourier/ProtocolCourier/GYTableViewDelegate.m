//
//  GYTableViewDelegate.m
//  ProtocolCourier
//
//  Created by GuYi on 2017/5/14.
//
//

#import "GYTableViewDelegate.h"

@implementation GYTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击第%tu个cell", indexPath.row);
}

@end
