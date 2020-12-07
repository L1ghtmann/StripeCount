#import <UIKit/UIKit.h>

//Lightmann
//Made during COVID-19
//StripeCount

@interface _UITableViewHeaderFooterViewLabel : UILabel
-(id)_viewControllerForAncestor;
@end

@interface ZBPackageListTableViewController : UIViewController{
	int numberOfPackages;
}
@property UITabBarController *tabBarController;
@property (nonatomic, retain) UILabel *stripeCount;
-(void)reconfigureStripeCount;
@end

//local 
CGFloat labelXOffset;
CGFloat labelWidth;
NSUserDefaults *configuration;


//TWEAK
//get values we'll use for positioning later
%hook _UITableViewHeaderFooterViewLabel
-(void)setFrame:(CGRect)frame{
	%orig;

	if([[self _viewControllerForAncestor] isMemberOfClass:%c(ZBPackageListTableViewController)]){
		labelXOffset = self.frame.origin.x;
		labelWidth = self.frame.size.width;
	}
}
%end

//where the magic happens . . .
%hook ZBPackageListTableViewController
%property (nonatomic, retain) UILabel *stripeCount;
-(void)viewDidAppear:(BOOL)appear{
	%orig;

	//if on packages page (index 3) and label hasn't been made yet... 
	if(self.tabBarController.selectedIndex == 3 && !self.stripeCount){
		//Create label																				
		self.stripeCount = [[UILabel alloc] initWithFrame:CGRectMake(labelXOffset,-18.5,labelWidth,32)];

		//RTL Support
		if([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft){
			CGRect frame = self.stripeCount.frame;
			self.stripeCount.frame = CGRectMake((labelXOffset+labelWidth-frame.size.width), frame.origin.y, frame.size.width, frame.size.height);
		}		

		//configure label based on our dylib_config bool (default is false)
		configuration = [NSUserDefaults standardUserDefaults]; 
		if([configuration boolForKey:@"sc_dylib_config"]){
			//get # of dylibs -- since the folder contains a .plist for every .dylib we divide by 2 to get just the dylib count 
			int dylibCount = ([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/usr/lib/TweakInject" error:nil] count]/2);
			self.stripeCount.text = [@"Dylibs: " stringByAppendingString:[NSString stringWithFormat:@"%d", dylibCount]];
		}
		else{
			int totalCount = MSHookIvar<int>(self, "numberOfPackages");
			self.stripeCount.text = [@"Total: " stringByAppendingString:[NSString stringWithFormat:@"%d", totalCount]];
		}

		//add StripeCount to Zebra (tableview) 
		[self.view addSubview:self.stripeCount];

		//create and add tap gesture to tableview 
		UITapGestureRecognizer *configGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reconfigureStripeCount)];
		configGesture.numberOfTapsRequired = 2;
		[self.view addGestureRecognizer:configGesture];
	}
}

%new
// Respond to tap gesture 
-(void)reconfigureStripeCount{
	//if config is set to default, change to dylib 
	if(![configuration boolForKey:@"sc_dylib_config"]){
		int dylibCount = ([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/usr/lib/TweakInject" error:nil] count]/2);
		self.stripeCount.text = [@"Dylibs: " stringByAppendingString:[NSString stringWithFormat:@"%d", dylibCount]];
		[configuration setBool:YES forKey:@"sc_dylib_config"]; //change completed
	} 
	//if config is set to dylib, change to default
	else{ 
		int totalCount = MSHookIvar<int>(self, "numberOfPackages");
		self.stripeCount.text = [@"Total: " stringByAppendingString:[NSString stringWithFormat:@"%d", totalCount]];
		[configuration setBool:NO forKey:@"sc_dylib_config"]; //change completed
	}
}
%end
