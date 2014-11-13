//
//  ViewController.m
//  bleTerminal
//
//  Created by Ladvien on 10/27/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

// bleTerminal Blue B: .976471 R:.015686 G:.270588
// Color schemes.
#define mainBlue_B .976471
#define mainBlue_R .015686
#define mainBlue_G .270588

// Corner roundness.
#define cornerRadiusConst 10.0
#define openingMessage @"bleTerminal v.05"

// 1. Add window resizing with keyboard.
// http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present
// 2. Add change font size.
// 3. Add change font.

@interface ViewController ()



// Buttons
- (IBAction)clearTerminalButton:(id)sender;
- (IBAction)sendButton:(id)sender;
- (IBAction)backgroundColorButton:(id)sender;
- (IBAction)textColorButton:(id)sender;
- (IBAction)fontSizeButton:(id)sender;
- (IBAction)fontStyleButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *scanButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UIButton *textColorButton;
@property (strong, nonatomic) IBOutlet UIButton *fontSizeButton;
@property (strong, nonatomic) IBOutlet UIButton *fontStyleButton;

// Main View window.
@property (strong, nonatomic) IBOutlet UIView *mainView;

// Status bar.
@property (strong, nonatomic) IBOutlet UIView *topBarView;

// Device View.
@property (strong, nonatomic) IBOutlet UIView *tableViewContainer;
@property (strong, nonatomic) IBOutlet UIView *scanForDevicesView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *deviceView;

// Font Style and Size.
@property (strong, nonatomic) IBOutlet UITableView *fontStyle;
@property (strong, nonatomic) IBOutlet UITableView *fontSize;


// RX text boxes.
@property (strong, nonatomic) IBOutlet UITextView *rxTextView;
@property (strong, nonatomic) IBOutlet UITextField *sendTextBox;
@property (strong, nonatomic) IBOutlet UIView *rxTextViewFrame;
@property (strong, nonatomic) IBOutlet UIView *sendTextFrame;

// Connection Status on the top bar.
@property (strong, nonatomic) IBOutlet UILabel *connectedLabel;

@property (strong, nonatomic) IBOutlet UIView *menuView;

//Not yet used.
@property (strong, nonatomic) NSTimer *rssiTimer;

// Class object for the color picker view.
@property (strong, nonatomic) IBOutlet NKOColorPickerView *pickerView;

// Number mapping method.
-(float)mapNumber: (float)x minimumIn:(float)minIn maximumIn:(float)maxIn minimumOut:(float)minOut maximumOut:(float)maxOut;

// Run when app enters background.
-(void)enteredBackground;

// Run when app is about to terminate.
-(void)willTerminate;

// Color scheming methods.
-(void)updateBackgroundColor;
-(void)updateTextColor;

// Hides all open windows.
-(void)hideAllWindows;

@end

@implementation ViewController

// For controlling what items to change color.
bool textColorFlag = false;
bool backgroundColorFlag = false;
short deviceViewSelector = 0;

UIColor *selectedBackGroundColor;
UIColor *selectedTextColor;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rxTextView.text = openingMessage;
    // Let's get notifications for background and termination.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    ViewController *mappedNumber = [[ViewController alloc] init];
    float de;
    de = [mappedNumber mapNumber:4 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    
    float bgB = [mappedNumber mapNumber:127 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float bgG = [mappedNumber mapNumber:67 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float bgR = [mappedNumber mapNumber:44 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    
    
    float textB = [mappedNumber mapNumber:104 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float textG = [mappedNumber mapNumber:206 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];
    float textR = [mappedNumber mapNumber:245 minimumIn:0 maximumIn:255 minimumOut:0 maximumOut:1];

    //////////////////////////////////////////////////////////
    
    selectedBackGroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1];
    selectedTextColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1];
    
    //Color did change block declaration
    self.pickerView.didChangeColorBlock = ^(UIColor *color){
        if (textColorFlag == true) {
            selectedTextColor = color;
            [self updateTextColor];

        }
        else if (backgroundColorFlag == true)
        {
            selectedBackGroundColor = color;
            [self updateBackgroundColor];
    
        }
    };
    
    

    
    //////////////////////////////////////////////////////////
    
    // Let's make the BLE happen.
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    // Main view UI setup.
    self.mainView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;

    // Table view UI.
    self.tableViewContainer.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.tableView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;

    
    [self.tableView setBackgroundColor:selectedBackGroundColor];
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
    self.rxTextViewFrame.layer.cornerRadius = cornerRadiusConst;
    self.rxTextViewFrame.layer.borderWidth = 3;
    [self.rxTextView setTextColor:[UIColor colorWithRed:textR green:textG blue:textB alpha:1]];

    // Menu text view UI.
    self.menuView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.menuView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.menuView.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.menuView.layer.shadowColor = [UIColor blackColor].CGColor;
    // Shadow and border.
    self.menuView.layer.shadowOpacity = 0.5f;
    self.menuView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.menuView.layer.shadowRadius = 5.0f;
    self.menuView.layer.masksToBounds = NO;
    self.menuView.layer.cornerRadius = cornerRadiusConst;
    self.menuView.layer.borderWidth = 3;
    
    // Setup shadow for Devices TableView.
    self.deviceView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.deviceView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.deviceView.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.deviceView.layer.shadowColor = [UIColor blackColor].CGColor;

    // Shadow and border.
    self.deviceView.layer.shadowOpacity = 0.5f;
    self.deviceView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.deviceView.layer.shadowRadius = 5.0f;
    self.deviceView.layer.masksToBounds = NO;
    self.deviceView.layer.cornerRadius = cornerRadiusConst;
    self.deviceView.layer.borderWidth = 3;
    [self.tableView setSeparatorColor:[UIColor colorWithRed:textR green:textG blue:textB alpha:1]];
   
    // Setup shadow for Pickerview.
    self.pickerView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.pickerView.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    self.pickerView.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.pickerView.layer.shadowColor = [UIColor blackColor].CGColor;
    // Shadow and border.
    self.pickerView.layer.shadowOpacity = 0.5f;
    self.pickerView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.pickerView.layer.shadowRadius = 5.0f;
    self.pickerView.layer.masksToBounds = NO;
    self.pickerView.layer.cornerRadius = cornerRadiusConst;
    self.pickerView.layer.borderWidth = 3;

    
    
    // Send text box UI.
    self.sendTextFrame.layer.shadowOpacity = 0.5f;
    self.sendTextFrame.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.sendTextFrame.layer.shadowRadius = 5.0f;
    self.sendTextFrame.layer.masksToBounds = NO;
    self.sendTextFrame.layer.cornerRadius = cornerRadiusConst;
    self.sendTextFrame.layer.borderWidth = 3;
    self.sendTextFrame.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.sendTextFrame.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    [self.sendTextBox setTextColor:[UIColor colorWithRed:textR green:textG blue:textB alpha:1]];

    // Clear Button
    [self.sendButton setEnabled:YES ]; // disables
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal]; // sets text
    self.sendButton.layer.shadowOpacity = 0.5f;
    self.sendButton.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.sendButton.layer.shadowRadius = 5.0f;
    self.sendButton.layer.borderWidth = 1;
    self.sendButton.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.sendButton.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    
    // Clear Button
    [self.clearButton setEnabled:YES ]; // disables
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal]; // sets text
    self.clearButton.layer.shadowOpacity = 0.5f;
    self.clearButton.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.clearButton.layer.shadowRadius = 5.0f;
    self.clearButton.layer.borderWidth = 1;
    self.clearButton.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.clearButton.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;


    // Background Button
    [self.backgroundButton setEnabled:YES ]; // disables
    [self.backgroundButton setTitle:@"Background" forState:UIControlStateNormal]; // sets text
    self.backgroundButton.layer.shadowOpacity = 0.5f;
    self.backgroundButton.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.backgroundButton.layer.shadowRadius = 5.0f;
    self.backgroundButton.layer.borderWidth = 1;
    self.backgroundButton.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.backgroundButton.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    
    // Text Button
    [self.textColorButton setEnabled:YES ]; // disables
    [self.textColorButton setTitle:@"Text" forState:UIControlStateNormal]; // sets text
    self.textColorButton.layer.shadowOpacity = 0.5f;
    self.textColorButton.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.textColorButton.layer.shadowRadius = 5.0f;
    self.textColorButton.layer.borderWidth = 1;
    self.textColorButton.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.textColorButton.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;

    // Font Size Button
    [self.fontSizeButton setEnabled:YES ]; // disables
    [self.fontSizeButton setTitle:@"Font Size" forState:UIControlStateNormal]; // sets text
    self.fontSizeButton.layer.shadowOpacity = 0.5f;
    self.fontSizeButton.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.fontSizeButton.layer.shadowRadius = 5.0f;
    self.fontSizeButton.layer.borderWidth = 1;
    self.fontSizeButton.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.fontSizeButton.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;
    
    // Font Style Button
    [self.fontStyleButton setEnabled:YES ]; // disables
    [self.fontStyleButton setTitle:@"Font Style" forState:UIControlStateNormal]; // sets text
    self.fontStyleButton.layer.shadowOpacity = 0.5f;
    self.fontStyleButton.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.fontStyleButton.layer.shadowRadius = 5.0f;
    self.fontStyleButton.layer.borderWidth = 1;
    self.fontStyleButton.layer.borderColor = [UIColor colorWithRed:textR green:textG blue:textB alpha:1].CGColor;
    self.fontStyleButton.layer.backgroundColor = [UIColor colorWithRed:bgR green:bgG blue:bgB alpha:1].CGColor;


    
    /*
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
    [self.connectedLabel setTextColor:[UIColor greenColor]];
    self.connectedLabel.text = [NSString stringWithFormat:@"Connected: %@", self.selectedPeripheral.name];
    
    
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

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectedLabel.text = [NSString stringWithFormat:@"Not Connected"];
    [self.connectedLabel setTextColor:[UIColor redColor]];
}

# pragma mark - table controller
////////////////////// Device Table View //////////////////

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(deviceViewSelector == 0)
    {
        //This counts how many items are in the deviceList array.
    
    }
    return [self.devices count];
}




- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This is a handle for the tableView.
    static NSString * bleTerminal = @"bleTerminal";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bleTerminal];

    if(deviceViewSelector == 0)
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
        

        
        //NSLog(@"%@", bleTerminal);
        
        // Get cell objects.;

        
        /////////////////////////END/////////////////////////////
        
        [cell setBackgroundColor:selectedBackGroundColor];
        [cell.contentView setBackgroundColor:selectedBackGroundColor];
        
        // List all the devices in the table view.
        if([indexPath row] < [uuids count]){
            // Don't list a device if there isn't one.
            if (devices)
            {
                UILabel *uuidLabel = (UILabel *)[cell.contentView viewWithTag:1];
                UILabel *deviceLabel = (UILabel *)[cell.contentView viewWithTag:2];
                [uuidLabel setBackgroundColor:selectedBackGroundColor];
                [deviceLabel setBackgroundColor:selectedBackGroundColor];
                [uuidLabel setTextColor:selectedTextColor];
                [deviceLabel setTextColor:selectedTextColor];
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
        

    }
    else if(deviceViewSelector == 1)
    {
        NSLog(@"Text");
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(deviceViewSelector == 0)
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
                [self disconnectPeripheral];
                
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
    else if(deviceViewSelector == 1)
    {
        NSLog(@"Text");
    }
 
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Sets the height for each row to 90, the same size as the custom cell.
    return 60;
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

- (void)disconnectPeripheral
{
    NSLog(@"RUN");
    [self.centralManager cancelPeripheralConnection:_selectedPeripheral];
}


-(void)enteredBackground
{
    [self disconnectPeripheral];
    NSLog(@"Background");
}

-(void)willTerminate
{
    [self disconnectPeripheral];
    NSLog(@"Will terminate");
}

- (IBAction)backgroundColorButton:(id)sender {
    
    backgroundColorFlag = true;
    if (self.pickerView.hidden == true && self.deviceView.hidden == true) {
        self.pickerView.hidden = false;
    }
    else if (self.pickerView.hidden == false)
    {
        [self hideAllWindows];
    }
    
}

- (IBAction)textColorButton:(id)sender {

    textColorFlag = true;
    if (self.pickerView.hidden == true && self.deviceView.hidden == true) {
        self.pickerView.hidden = false;
    }
    else if (self.pickerView.hidden == false)
    {
        [self hideAllWindows];
    }
}

- (IBAction)scanButton:(id)sender {

    deviceViewSelector = 0;
    if (self.scanForDevicesView.hidden == true && self.pickerView.hidden == true) {
        self.scanForDevicesView.hidden = false;
    }
    else if (self.scanForDevicesView.hidden == false)
    {
        [self hideAllWindows];;
    }
}


-(void)hideAllWindows;
{
    textColorFlag = false;
    backgroundColorFlag = false;
    self.pickerView.hidden = true;
    self.deviceView.hidden = true;
}

-(void)updateBackgroundColor
{
    [self.tableViewContainer setBackgroundColor:selectedBackGroundColor];
    [self.mainView setBackgroundColor:selectedBackGroundColor];
    [self.tableView setBackgroundColor:selectedBackGroundColor];
    [self.tableViewContainer setBackgroundColor: selectedBackGroundColor];
    [self.rxTextView setBackgroundColor:selectedBackGroundColor];
    [self.rxTextViewFrame setBackgroundColor: selectedBackGroundColor];
    [self.clearButton setBackgroundColor:selectedBackGroundColor];
    [self.backgroundButton setBackgroundColor:selectedBackGroundColor];
    [self.textColorButton setBackgroundColor:selectedBackGroundColor];
    [self.sendButton setBackgroundColor:selectedBackGroundColor];
    [self.sendTextBox setBackgroundColor:selectedBackGroundColor];
    [self.sendTextFrame setBackgroundColor:selectedBackGroundColor];
    [self.sendTextFrame setBackgroundColor:selectedBackGroundColor];
    [self.deviceView setBackgroundColor:selectedBackGroundColor];
    [self.tableView setBackgroundColor:selectedBackGroundColor];
    [self.menuView setBackgroundColor:selectedBackGroundColor];
    [self.pickerView setBackgroundColor:selectedBackGroundColor];
    [self.fontSizeButton setBackgroundColor:selectedBackGroundColor];
    [self.fontStyleButton setBackgroundColor:selectedBackGroundColor];
    
    self.tableViewContainer.layer.backgroundColor = (selectedBackGroundColor).CGColor;
    self.tableView.layer.backgroundColor = (selectedBackGroundColor).CGColor;
    [self.tableView reloadData];

    
}

-(void)updateTextColor
{
    [self.rxTextView setTextColor:selectedTextColor];
    [self.sendButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
    [self.textColorButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
    [self.backgroundButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
    [self.clearButton setTitleColor:selectedTextColor forState:UIControlStateNormal];
    [self.sendTextBox setTextColor:selectedTextColor];
    if ([self.rxTextView.text isEqual:openingMessage]) {
        self.rxTextView.text = @"";
        self.rxTextView.text = openingMessage;
        NSLog(@"BLAG");
    }
    
}
- (IBAction)fontSizeButton:(id)sender {
    deviceViewSelector = 1;
    [self.tableView reloadData];
    if (self.scanForDevicesView.hidden == true && self.pickerView.hidden == true) {
        self.scanForDevicesView.hidden = false;
    }
    else if (self.scanForDevicesView.hidden == false)
    {
        [self hideAllWindows];;
    }
    
}

- (IBAction)fontStyleButton:(id)sender {
}

@end
