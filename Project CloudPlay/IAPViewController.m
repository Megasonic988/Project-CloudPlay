//
//  IAPViewController.m
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-04-28.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import "IAPViewController.h"
#import "BuyUnlimitedIAPHelper.h"

@interface IAPViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) NSArray *products;

@end

@implementation IAPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[BuyUnlimitedIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
    
    SKProduct * product = (SKProduct *) _products[0];
    NSLog(@"%@", product.localizedTitle);
    self.infoLabel.text = product.localizedTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reload:(UIButton *)sender {
    [[BuyUnlimitedIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
    SKProduct * product = (SKProduct *)[_products firstObject];
    NSLog(@"%@", product.localizedTitle);
    self.infoLabel.text = product.localizedTitle;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
