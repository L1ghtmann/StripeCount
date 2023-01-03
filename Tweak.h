#import <UIKit/UIKit.h>

@interface _UITableViewHeaderFooterViewLabel : UILabel
-(UIViewController *)_viewControllerForAncestor;
@end

@interface ZBPackageListTableViewController : UITableViewController {
	int numberOfPackages;
}
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UILabel *stripeCount;
-(void)reconfigureStripeCount;
@end
