#import <UIKit/UIKit.h>

@interface _UITableViewHeaderFooterViewLabel : UILabel
-(UIViewController *)_viewControllerForAncestor;
@end

@interface ZBPackageListTableViewController : UIViewController{
	int numberOfPackages;
}
@property UITabBarController *tabBarController;
@property (nonatomic, retain) UILabel *stripeCount;
-(void)reconfigureStripeCount;
@end
