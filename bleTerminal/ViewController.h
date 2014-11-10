//
//  ViewController.h
//  bleTerminal
//
//  Created by Ladvien on 10/27/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UIView+blurEffect.h"
#import "AppDelegate.h"
#import "NKOColorPickerView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>

// Instance of Central Manager.
@property (strong, nonatomic) CBCentralManager *centralManager;
//Stores a list of dicovered devices, the key being their UUID.
@property (strong, nonatomic) NSMutableDictionary *devices;
// Instance method, used to act when a peripheral is discovered.
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
// Instance method, used to act when a peripheral is selected to connect.
@property (nonatomic) CBPeripheral *selectedPeripheral;
// Holds UUID.
@property (readonly, nonatomic) CFUUIDRef UUID;
// Stores peripheral characteristics.
@property (strong, nonatomic) CBCharacteristic *characteristics;
@property (strong, nonatomic) NSMutableData *data;
@property (weak, nonatomic) UIColor *backGroundColor;
- (void)disconnectPeripheral;
@end

