#include "StripeCountRootListController.h"

@implementation StripeCountRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

//tints color of Switches
- (void)viewWillAppear:(BOOL)animated {
	[[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed:247.0f/255.0f green:249.0f/255.0f blue:250.0f/255.0f alpha:1.0]];
    [super viewWillAppear:animated];
}

@end
