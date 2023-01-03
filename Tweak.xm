//
//	Tweak.xm
//	StripeCount
//
//	Created by Lightmann during COVID-19
//

#import "Tweak.h"

CGFloat labelXOffset;
CGFloat labelWidth;

NSUInteger getDylibCount(){
	NSError *readErr = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries" error:&readErr];
	if(!readErr){
		return [[contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.dylib'"]] count];
	}
	else{
		return 0;
	}
}

// get values we'll use for positioning later
%hook _UITableViewHeaderFooterViewLabel
-(void)setFrame:(CGRect)frame{
	%orig;

	if([[self _viewControllerForAncestor] isMemberOfClass:%c(ZBPackageListTableViewController)]){
		labelXOffset = self.frame.origin.x;
		labelWidth = self.frame.size.width;
	}
}
%end

// where the magic happens . . .
%hook ZBPackageListTableViewController
%property (nonatomic, retain) UILabel *stripeCount;
-(void)viewDidAppear:(BOOL)appear{
	%orig;

	// if we're on the packages page (index 3) and stripeCount hasn't been made yet...
	if(self.tabBarController.selectedIndex == 3 && !self.stripeCount){
		// create label
		self.stripeCount = [[UILabel alloc] init];
		[self.view addSubview:self.stripeCount];

		[self.stripeCount setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self.stripeCount.heightAnchor constraintEqualToConstant:20].active = YES;
		[self.stripeCount.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:-12].active = YES;

		// RTL Support
		if([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft){
			[self.stripeCount.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:labelXOffset+labelWidth].active = YES;
		}
		else{
			[self.stripeCount.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:labelXOffset].active = YES;
		}

		// configure label based on our boolean (default is false)
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"sc_dylib_config"]){
			[self.stripeCount setText:[NSString stringWithFormat:@"Tweak Dylibs: %lu", getDylibCount()]];
		}
		else{
			int totalCount = MSHookIvar<int>(self, "numberOfPackages");
			[self.stripeCount setText:[NSString stringWithFormat:@"Total Packages: %d", totalCount]];
		}

		// create and add tap gesture to tableview
		UITapGestureRecognizer *configGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reconfigureStripeCount)];
		[configGesture setNumberOfTapsRequired:2];
		[self.view addGestureRecognizer:configGesture];
	}
}

%new
// respond to tap gesture
-(void)reconfigureStripeCount{
	// if config is set to total, change to dylib
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"sc_dylib_config"]){
		[self.stripeCount setText:[NSString stringWithFormat:@"Tweak Dylibs: %lu", getDylibCount()]];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sc_dylib_config"];
	}
	// if config is set to dylib, change to total
	else{
		int totalCount = MSHookIvar<int>(self, "numberOfPackages");
		[self.stripeCount setText:[NSString stringWithFormat:@"Total Packages: %d", totalCount]];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sc_dylib_config"];
	}
}
%end
