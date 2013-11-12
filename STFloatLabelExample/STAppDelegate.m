//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STAppDelegate.h"

#import "STFloatLabelExampleViewController.h"


@implementation STAppDelegate

- (void)setWindow:(UIWindow *)window {
    _window = window;
    [_window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow * const window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor whiteColor];

    STFloatLabelExampleViewController * const vc = [[STFloatLabelExampleViewController alloc] initWithNibName:nil bundle:nil];

    window.rootViewController = vc;

    self.window = window;

    if ([window respondsToSelector:@selector(setTintColor:)]) {
        window.tintColor = [UIColor greenColor];
    }

    return YES;
}

@end
