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
@end

//local
CGFloat labelXOffset;
CGFloat labelWidth;

//prefs
static BOOL isEnabled;
static int configuration;


%group tweak
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

	if(self.tabBarController.selectedIndex == 3 && !self.stripeCount){
		//Create label																				
		self.stripeCount = [[UILabel alloc] initWithFrame:CGRectMake(labelXOffset,-18.5,labelWidth,32)];

		//RTL Support
		if([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft){
			CGRect frame = self.stripeCount.frame;
			self.stripeCount.frame = CGRectMake((labelXOffset+labelWidth-frame.size.width), frame.origin.y, frame.size.width, frame.size.height);
		}		

		//craft label string and assign it 
		if(configuration == 1){
			//get # of dylibs -- since the folder contains a .plist for every .dylib we divide by 2 to get just the dylib count 
			int dylibCount = ([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/usr/lib/TweakInject" error:nil] count]/2);
			self.stripeCount.text = [@"Dylibs: " stringByAppendingString:[NSString stringWithFormat:@"%d", dylibCount]];
		}
		else{
			int totalCount = MSHookIvar<int>(self, "numberOfPackages");
			self.stripeCount.text = [@"Total: " stringByAppendingString:[NSString stringWithFormat:@"%d", totalCount]];
		}
	
		//add StripeCount to Zebra 
		[self.view addSubview:self.stripeCount];	
	}
}
%end
%end


//	PREFERENCES 
void preferencesChanged(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lightmann.stripecountprefs"];
	if(prefs){
  	  	isEnabled = ([prefs objectForKey:@"isEnabled"] ? [[prefs valueForKey:@"isEnabled"] boolValue] : YES );
		configuration = ([prefs objectForKey:@"configuration"] ? [[prefs valueForKey:@"configuration"] integerValue] : 0 );
	}
}

%ctor {
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesChanged, CFSTR("me.lightmann.stripecountprefs-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	if(isEnabled)
		%init(tweak);
}
