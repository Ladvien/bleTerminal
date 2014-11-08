//
//  ViewController.m
//  bleTerminal
//
//  Created by Ladvien on 10/27/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "ViewController.h"

// Color schemes.
#define mainBlue_B .976471
#define mainBlue_R .015686
#define mainBlue_G .270588


@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *scanButton;

// bleTerminal Blue B: .976471 R:.015686 G:.270588
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *topBarView;
@property (strong, nonatomic) IBOutlet UIView *tableViewContainer;
@property (strong, nonatomic) IBOutlet UIView *scanForDevicesView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *deviceView;
@property (strong, nonatomic) IBOutlet UITextView *rxTextView;
@property (strong, nonatomic) IBOutlet UITextField *sendTextBox;
@property (strong, nonatomic) IBOutlet UIView *rxTextViewFrame;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;


- (IBAction)clearTerminalButton:(id)sender;
- (IBAction)sendButton:(id)sender;
-(float)mapNumber: (float)x minimumIn:(float)minIn maximumIn:(float)maxIn minimumOut:(float)minOut maximumOut:(float)maxOut;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    ViewController *mappedNumber = [[ViewController alloc] init];
    float de;
    de = [mappedNumber mapNumber:4 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    
    float bgB = [mappedNumber mapNumber:127 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float bgG = [mappedNumber mapNumber:67 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float bgR = [mappedNumber mapNumber:44 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    
    
    float textB = [mappedNumber mapNumber:104 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float textG = [mappedNumber mapNumber:206 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float textR = [mappedNumber mapNumber:245 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    
    // Let's make the BLE happen.
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    // Main view UI setup.
    self.mainView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;

    // Table view UI.
    self.tableViewContainer.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;

    self.tableView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;

    // RX text view UI.
    self.rxTextView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.rxTextViewFrame.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.rxTextViewFrame.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.rxTextViewFrame.layer.shadowColor = [UIColor blackColor].CGColor;
    // Shadow and border.
    self.rxTextViewFrame.layer.shadowOpacity = 0.5f;
    self.rxTextViewFrame.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.rxTextViewFrame.layer.shadowRadius = 5.0f;
    self.rxTextViewFrame.layer.masksToBounds = NO;
    self.rxTextViewFrame.layer.cornerRadius = 30;
    self.rxTextViewFrame.layer.borderWidth = 3;
    [self.rxTextView setTextColor:[UIColor colorWithRed:textR green:textG blue:textB alpha:1]];
    
    // Send text box UI.
    self.sendTextBox.layer.shadowOpacity = 0.5f;
    self.sendTextBox.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.sendTextBox.layer.shadowRadius = 5.0f;
    self.sendTextBox.layer.masksToBounds = NO;
    self.sendTextBox.layer.cornerRadius = 30;
    self.sendTextBox.layer.borderWidth = 3;
    
    /*
    // Setup shadow for Devices TableView.
    self.devicesView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.devicesView.layer.shadowOpacity = 0.5f;
    self.devicesView.layer.shadowOffset = CGSizeMake(20.0f, 20.0f);
    self.devicesView.layer.shadowRadius = 5.0f;
    self.devicesView.layer.masksToBounds = NO;
    
    // Setup border for view backdrop.
    //self.devicesView.layer.cornerRadius = 30;
    self.devicesView.layer.borderWidth = 20.0;
    self.devicesView.layer.borderColor = [UIColor colorWithRed:.10588 green:.25098 blue:.46666 alpha:1].CGColor;
    
    // Set the steer slider's thumb control image.
    [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    // This is a redneck way of removing the steer slider track.
    [self.steerSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    
    // Do the same for the acceleration control.
    [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    [self.accelerationSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    
    // Turns the acceleration slider vertical.
    self.accelerationSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.steerSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    //Let's set a timer to refresh RSSI.
    self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                      target:self
                                                    selector:@selector(steerSliderTick)
                                                    userInfo:nil
                                                     repeats:YES];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // Turn on Bluetooth error msg.
        return;
        
    }
    
    // Device is on, let's scan for peripherals.
    if (central.state == CBCentralManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Set peripheral.
    _discoveredPeripheral = peripheral;
    
    //Create a string for the discovered peripheral.
    NSString * uuid = [[peripheral identifier] UUIDString];
    
    if (uuid) {
        [self.devices setObject:peripheral forKey:uuid];
    }
    
    // FINISH
    [self.tableView reloadData];
    
}

- (NSMutableDictionary *)devices
{
    // Make sure the device dictionary is empty.
    if(_devices == nil)
    {
        _devices = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _devices;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // Set the peripheral delegate
    peripheral.delegate = self;
    // Set the peripheral method's discoverServices to nil,
    // this searches for all services, it's slower but inclusive.
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService * service in [peripheral services])
    {
        // Discover all characteristics for this service.
        [_selectedPeripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Enumerates through all services on the connected peripheral.
    for (CBCharacteristic * character in [service characteristics])
    {
        // Discover all descriptors for each characteristic.
        [_selectedPeripheral discoverDescriptorsForCharacteristic:character];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Store the data from the UUID in byte format, save in bytes variable.
    const char * bytes = [(NSData*)[[characteristic UUID]data] bytes];
    // Check to see if it is two bytes long and they are FF and E1.
    if (bytes && strlen(bytes) == 2 && bytes[0] == (char)255 && bytes[1] == (char)225)
        {
            // We set the connected peripheral data to the instance peripheral data.
            _selectedPeripheral = peripheral;
            for(CBService * service in [_selectedPeripheral services])
            {
                for (CBCharacteristic * characteristic in [service characteristics])
                {
                    // For every characteristic on every service, on the connected peripheral
                    // set the setNotifyValue to true.
                    [_selectedPeripheral setNotifyValue:true forCharacteristic:characteristic];
                    
                }
            }
        }
}

- (void)sendValue:(NSString *) str
{
    for (CBService * service in [_selectedPeripheral services])
    {
        for (CBCharacteristic * characteristic in [service characteristics])
        {
            // Create a string with all the data, formatted in ASCII.
            //NSString * strData = [[NSString alloc] initWithData:myData encoding:NSASCIIStringEncoding];
            // Add the end-of-transmission character to allow the
            // Arduino to parse the string
            str = [NSString stringWithFormat:@"%@\r", str];
            
            // Write the str variable with all our movement data.
            [_selectedPeripheral writeValue:[str dataUsingEncoding:NSASCIIStringEncoding]
                          forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            //NSLog(@"%2x", str);
        }
    }
}



-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString * joe = [[NSString alloc] initWithData:[characteristic value] encoding:NSASCIIStringEncoding];
    
    
    self.rxTextView.text = [NSString stringWithFormat:@"%@%@", self.rxTextView.text, joe];
    [self.rxTextView scrollRangeToVisible:NSMakeRange([self.rxTextView.text length], 0)];
    //NSLog(@"%@", joe);
}


# pragma mark - table controller
////////////////////// Device Table View //////////////////

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //This counts how many items are in the deviceList array.
    return [self.devices count];
}




- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // This gets a sorted array from NSMutableDictionary.
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    // Setup a devices instance.
    CBPeripheral * devices = nil;
    
    
    // Go until we run out of devices.
    if ([indexPath row] < [uuids count])
    {
        // Set the peripherals based upon indexPath # from uuids array.
        devices = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];

    }
    
    /////////////////////////LOADS CUSTOM CELL/////////////////////////////
    
    // This is a handle for the tableView.
    static NSString * bleTerminal = @"bleTerminal";
    
    //NSLog(@"%@", bleTerminal);
    // Get cell objects.;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bleTerminal];
    
    /////////////////////////END/////////////////////////////
    
    // List all the devices in the table view.
    if([indexPath row] < [uuids count]){
        // Don't list a device if there isn't one.
        if (devices)
        {
            UILabel *uuidLabel = (UILabel *)[cell.contentView viewWithTag:1];
            UILabel *deviceLabel = (UILabel *)[cell.contentView viewWithTag:2];
            
            uuidLabel.text = [devices name];
            deviceLabel.text = [uuids objectAtIndex:[indexPath row]];
        }
    }
    
    // Add image on the left of each cell.
   // cell.  image = [UIImage imageNamed:@"oshw-logo-black.png"];
    // Sets background color for the cells.  Alpha = opacity.  Float, 0-1.
    // Will be used for device distance indication.  Let's have it as a base int.
    
    // Set the background color of the cells.
   // cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:(1) alpha:1];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create a sorted array of the found UUIDs.
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    // Only get enough devices or listed cells.
    if ([indexPath row] < [uuids count])
    {
        // Set the peripheral based upon the indexPath; uuid being the array.
        _selectedPeripheral = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
        
        // If there is a peripheral.
        if (_selectedPeripheral)
        {
            // Close current connection.
            [_centralManager cancelPeripheralConnection:_selectedPeripheral];
            // Connect to selected peripheral.
            [_centralManager connectPeripheral:_selectedPeripheral options:nil];
            // Hide the devices list.
            [UIView beginAnimations:@"fade in" context:nil];
            [UIView setAnimationDuration:1.0];
            [UIView commitAnimations];
            self.deviceView.hidden = true;
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Sets the height for each row to 90, the same size as the custom cell.
    return 60;
}
- (IBAction)scanButton:(id)sender {
    if(self.deviceView.hidden == true){
        self.deviceView.hidden = false;
    }
    else
    {
       self.deviceView.hidden = true;
    }
}

- (IBAction)sendButton:(id)sender {
    [self sendValue:self.sendTextBox.text];
    //NSLog(@"%@", self.sendTextBox.text);
    //self.sendTextBox.text = @"";
}
- (IBAction)clearTerminalButton:(id)sender {
    self.rxTextView.text = @"";
    //self.rxTextView.font = [UIFont fontWithName:@"arial" size:40];

    ViewController *mappedNumber = [[ViewController alloc] init];
    float de;
    de = [mappedNumber mapNumber:4 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    NSLog(@"%f", de);
}

-(void)updateBlur
{
    UIImage *image = [self.view.superview convertViewToImage];
    
}

-(float)mapNumber: (float)x minimumIn:(float)minIn maximumIn:(float)maxIn minimumOut:(float)minOut maximumOut:(float)maxOut;
{
    return ((x - minIn) * (maxOut - minOut)/(maxIn - minIn) + minOut);
}

@end
