//Lightmann
//Made during COVID-19
//StripeCount

@interface _UITableViewHeaderFooterViewLabel : UILabel
@end

@interface ZBPackageListTableViewController : UIViewController{
	int numberOfPackages;
}
-(void)populatePackages;//custom method called later
@end

BOOL onPackagesPage = NO;
BOOL stripeCountMade = NO;
CGFloat labelXOffset = nil;
CGFloat labelWidth = nil;



//Wouldn't normally hook this since it is widely used across iOS, but since StripeCount only injects into Zebra and it has only one tabbar it should be fine 
%hook UITabBar 
-(void)setSelectedItem:(UITabBarItem *)arg1 {
	%orig;

	//Determine when user is on the Packages page by checking to see if the tabbar's selected item is the Packages item
	if([arg1 isEqual:self.items[3]]){ 
		onPackagesPage = YES;
	} 
	else {
		onPackagesPage = NO;
	}
}
%end


//get values we'll use for calculations later
%hook _UITableViewHeaderFooterViewLabel
-(void)setFrame:(CGRect)frame{
	%orig;

	if(onPackagesPage){
		labelXOffset = self.frame.origin.x;
		labelWidth = self.frame.size.width;
	}
}
%end


%hook ZBPackageListTableViewController
-(void)refreshTable{
	%orig;

	//Delays creation of label so # of Packages has time to populate fully
	[self performSelector:@selector(populatePackages) withObject:nil afterDelay:0.1];
}
%new
-(void)populatePackages{
	if(onPackagesPage && !stripeCountMade){
		//Create label
		UILabel *stripeCount = [[UILabel alloc] initWithFrame:CGRectMake(labelXOffset,-18.5,80,32)];
		
		//RTL Support
		if([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft){
			CGRect frame = stripeCount.frame;
			stripeCount.frame = CGRectMake((labelXOffset+labelWidth-frame.size.width),frame.origin.y,frame.size.width,frame.size.height);
		}		

		//get # of installed packages and assign it to label
		int count = MSHookIvar<int>(self, "numberOfPackages");
		NSString *numOfTweaks = [NSString stringWithFormat:@"%d", count];
		NSString *baseString = @"Total: ";
		NSString *stripeCountText = [baseString stringByAppendingString:numOfTweaks];

		stripeCount.text = stripeCountText;
	
		//Add to tableview 
		[self.view addSubview:stripeCount];	
		stripeCountMade = YES;
	}
}
%end
