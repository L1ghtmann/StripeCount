//Lightmann
//Made during COVID-19
//StripeCount

@interface _UINavigationBarLargeTitleView : UIView
@property (nonatomic,copy) NSString * title;         
@property (nonatomic,readonly) UIView * accessibilityTitleView; //UILabel in this case
@end

@interface ZBPackageListTableViewController : UIViewController{
	int numberOfPackages;
}
-(void)populateArrays;//custom method called later
@end

BOOL onPackagesPage = NO;
BOOL stripeCountMade = NO;
CGFloat labelXOffset = nil;
CGFloat labelWidth = nil;


%hook UINavigationBar
-(void)setFrame:(CGRect)arg1 {
	%orig;

	//Determine when user is no longer on main Packages page
	if([self.topItem.title isEqualToString:@"Packages"]){
		onPackagesPage = YES;
	} 
	else {
		onPackagesPage = NO;
	}
}
%end

%hook _UINavigationBarLargeTitleView
-(void)setTitle:(NSString *)arg1 {
	%orig;

	//Get length and offset of Packages label (x position varies based on device size)
	if([self.title isEqualToString:@"Packages"]){
		labelXOffset = self.accessibilityTitleView.frame.origin.x;
		labelWidth = self.accessibilityTitleView.frame.size.width;
	}
}
%end

%hook ZBPackageListTableViewController
-(void)refreshTable{
	%orig;

	//Delays creation of label so array has time to populate fully
	[self performSelector:@selector(populateArrays) withObject:nil afterDelay:0.1];
}
%new
-(void)populateArrays{
	if(onPackagesPage && !stripeCountMade){
		//Create label
		UILabel *stripeCount = [[UILabel alloc] initWithFrame:CGRectMake(((labelXOffset+labelWidth)+3.25),-40,48,32)];
		
		//get # of installed packages and assign it to label
		int count = MSHookIvar<int>(self, "numberOfPackages");
		NSString *numOfTweaks = [NSString stringWithFormat:@"%d", count];
		stripeCount.text = numOfTweaks;
	
		//Add to tableview 
		[self.view addSubview:stripeCount];	
		stripeCountMade = YES;
	}
}
%end
