//
//  TestBLEViewController.m
//  TestBLE
//
//  Created by NeuroSky on 5/8/13.
//  Copyright (c) 2013 NeuroSky. All rights reserved.
//

#import "TestBLEViewController.h"

@interface TestBLEViewController ()

@end

static NSString * const kServiceUUID = @"039AFFF0-2C94-11E3-9E06-0002A5D5C51B";
static NSString * const kCharacteristicUUID = @"039AFFF4-2C94-11E3-9E06-0002A5D5C51B";
NSData * myvalue;
Byte byte[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};

@implementation TestBLEViewController


@synthesize manager;
@synthesize customCharacteristic;
@synthesize customService;
@synthesize SendDataButton;
@synthesize Tipslabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"capture.txt"];
    
    Tipslabel.text = @"No Central Subscribe this Service yet";
    SendDataButton.hidden = YES;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    filePath = [mainBundle pathForResource:@"cap" ofType:@"txt"];
    
    manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    [self peripheralManagerDidUpdateState:manager];
    
    myvalue = [[NSData alloc] initWithBytes:byte length:21];
   // [self sendDataby10];
   // [self performSelectorInBackground:@selector(sendDataby10) withObject:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{

    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            NSLog(@"CBPeripheralManagerStatePoweredOn");

            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
            
        default:
            NSLog(@"PM did change state");
            break;
    }

}



-(void)setupService{
    
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    
    customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    [customService setCharacteristics:@[customCharacteristic]];
    
    [manager addService:customService];
    NSLog(@"Adding Service!!");
    
}
//开始广播
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        [manager startAdvertising:@{CBAdvertisementDataLocalNameKey: @"ICServer",CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceUUID]]}];
        NSLog(@"Service Added Successfully !!!");
    }

}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{

}
//检测是否有中央接受信息
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    //generate data for sending to Central
    //[self.manager updateValue:myvalue forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
    
    Tipslabel.text = @"Some Central Subscribe this Service,Tap SendData Button";
    SendDataButton.hidden = NO;
   // [self SendData];
    NSLog(@"========");
    [self performSelectorInBackground:@selector(sendDataby10) withObject:nil];

}
//检测是否有中央取消接受信息
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{

    NSLog(@"Central Unsubscribe Character");
}




- (IBAction)OpenButtonClicked:(id)sender {
    //[self setupService];
    


}

- (IBAction)CloseButtonClicked:(id)sender {
    //[self.manager updateValue:myvalue forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
}

- (IBAction)SendButtonClicked:(id)sender {
    [self performSelectorInBackground:@selector(SendData) withObject:nil];
    
}
-(void)sendDataby10{

    NSString *cont = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *line=[cont componentsSeparatedByString:@"\n"];
  // NSLog(@"array:%@",line);
    for (int i=0; i<line.count; i++) {
        NSString *str = [line objectAtIndex:i];
        NSData *data= [str dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"data:%@",data);
        [self.manager updateValue:data forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
        usleep(1953);
    }
}


//start send data which in "capture.txt"
-(void)SendData{
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    [inputStream open];
    
    //int index = 0;
    
    NSInteger maxLength = 16;
    
    uint8_t readBuffer[maxLength];
    
    BOOL endOfStream = NO;
    
    while (!endOfStream) {
        NSInteger bytesRead = [inputStream read:readBuffer maxLength:maxLength];
        
        if (bytesRead == 0) {
            endOfStream = YES;
        }else if (bytesRead == -1){
            endOfStream = YES;
        }else{
            
            NSData *data = [[NSData alloc] initWithBytesNoCopy:readBuffer length:bytesRead];
            
            [self.manager updateValue:data forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
        
        }
        //index++;
        //NSLog(@"Sleep:%d",index);
        
        usleep(10000);

    }
    
    [inputStream close];

}











@end
