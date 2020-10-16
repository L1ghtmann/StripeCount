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
NSString *countText;
int dylibCount;

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
		self.stripeCount = [[UILabel alloc] initWithFrame:CGRectMake(labelXOffset,-18.5,80,32)];

		//RTL Support
		if([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft){
			CGRect frame = self.stripeCount.frame;
			self.stripeCount.frame = CGRectMake((labelXOffset+labelWidth-frame.size.width), frame.origin.y, frame.size.width, frame.size.height);
		}		

		//craft label string and assign it 
		if(configuration == 1){
			countText = [@"Dylibs: " stringByAppendingString:[NSString stringWithFormat:@"%d", dylibCount]];
		}
		else{
			int totalCount = MSHookIvar<int>(self, "numberOfPackages");
			countText = [@"Total: " stringByAppendingString:[NSString stringWithFormat:@"%d", totalCount]];
		}

		self.stripeCount.text = countText;
	
		//add StripeCount to Zebra 
		[self.view addSubview:self.stripeCount];	
	}
}
%end
%end


//	PREFERENCES 
static void loadPrefs() {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.lightmann.stripecountprefs.plist"];

  if(prefs){
    isEnabled = ( [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES );
	configuration = ( [prefs valueForKey:@"configuration"] ? [[prefs valueForKey:@"configuration"] integerValue] : 0 );
  }
}

static void initPrefs() {
  // Copy the default preferences file when the actual preference file doesn't exist
  NSString *path = @"/User/Library/Preferences/me.lightmann.stripecountprefs.plist";
  NSString *pathDefault = @"/Library/PreferenceBundles/StripeCountPrefs.bundle/defaults.plist";
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if(![fileManager fileExistsAtPath:path]) {
    [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
  }
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("me.lightmann.stripecountprefs-updated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();

	if(isEnabled)
		%init(tweak);

	//get # of dylibs -- since the folder contains a .plist for every .dylib we divide by 2 to get just the dylib count 
	if(configuration == 1)
		dylibCount = ([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/usr/lib/TweakInject" error:nil] count]/2);
}
