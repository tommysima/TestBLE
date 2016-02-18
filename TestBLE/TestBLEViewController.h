//
//  TestBLEViewController.h
//  TestBLE
//
//  Created by NeuroSky on 5/8/13.
//  Copyright (c) 2013 NeuroSky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface TestBLEViewController : UIViewController<CBPeripheralManagerDelegate>{

    NSString *filePath;

}

@property(nonatomic,strong)CBPeripheralManager *manager;
@property(nonatomic,strong)CBMutableCharacteristic *customCharacteristic;
@property(nonatomic,strong)CBMutableService *customService;

- (IBAction)OpenButtonClicked:(id)sender;
- (IBAction)CloseButtonClicked:(id)sender;
- (IBAction)SendButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *Tipslabel;
@property (weak, nonatomic) IBOutlet UIButton *SendDataButton;

@end
