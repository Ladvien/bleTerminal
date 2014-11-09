//
//  AppDelegate.m
//  bleTerminal
//
//  Created by Ladvien on 10/27/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) ViewController *someClassObject;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //self.someClassObject = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //[self.someClassObject disconnectPeripheral];
    //[self.someClassObject.centralManager cancelPeripheralConnection:self.someClassObject.selectedPeripheral];
    //NSLog(@"%@", self.someClassObject.selectedPeripheral);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didEnterBackground" object:nil userInfo:nil];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    
}

@end
