//
//  ViewController.m
//  ProtocolCourier
//
//  Created by GuYi on 2017/5/13.
//
//

#import "ViewController.h"
#import "GYTableViewDelegate.h"
#import "GYTableViewDataSource.h"
#import "GYScrollViewDelegate.h"
#import "ProtocolCourier.h"

@interface ViewController ()
@property (nonatomic, strong) IBOutlet UILabel *offsetLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GYTableViewDelegate *tableViewDelegate;
@property (nonatomic, strong) GYTableViewDataSource *tableviewDataSource;
@property (nonatomic, strong) GYScrollViewDelegate *scrollViewDelegate;

@property (nonatomic, strong) ProtocolCourier<UITableViewDelegate> *tableViewDelegateCourier;
@property (nonatomic, strong) ProtocolCourier<UITableViewDataSource> *tableViewDataSourceCourier;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewDelegate = [[GYTableViewDelegate alloc] init];
    self.tableviewDataSource = [[GYTableViewDataSource alloc] init];
    self.scrollViewDelegate = [[GYScrollViewDelegate alloc] init];
    self.scrollViewDelegate.label = self.offsetLabel;
    
    self.tableViewDelegateCourier = CreateProtocolCourier(UITableViewDelegate, self.tableViewDelegate, self.scrollViewDelegate);
    self.tableViewDataSourceCourier = CreateProtocolCourier(UITableViewDataSource, self.tableviewDataSource);
    
    self.tableView.delegate = self.tableViewDelegateCourier;
    self.tableView.dataSource = self.tableViewDataSourceCourier;
}

@end
