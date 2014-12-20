//
//  MasterViewController.m
//  StockMac
//
//  Created by jn11585852 on 14/12/20.
//  Copyright (c) 2014年 JiangNan. All rights reserved.
//

#import "MasterViewController.h"
#import "ScaryBugDoc.h"
#import "ScaryBugData.h"

#define kGoldPercent191 0.191
#define kGoldPercent382 0.382
#define kGoldPercent618 0.618
#define kGoldPercent809 0.809

static NSString* kStockMacPointAKey = @"StockMac.A";
static NSString* kStockMacPointBKey = @"StockMac.B";
static NSString* kStockMacPointCKey = @"SotckMac.C";
static NSString* kStockMacPointDKey = @"StockMac.D";
static NSString* kStockMacStopKey   = @"StockMac.Stop";
static NSString* kStockMacWave4LowestPointKey = @"StockMac.Wave4LowestPoint";
static NSString* kUserDefaultKey = @"StockMac";

@interface MasterViewController ()

// General view
@property (weak) IBOutlet NSTabView *tabView;

// Tab 1 - Gold

@property (weak) IBOutlet NSTextField *maxTextField;
@property (weak) IBOutlet NSTextField *minTextField;
@property (weak) IBOutlet NSTextField *midTextField;
@property (weak) IBOutlet NSTextField *rangeTextField;

@property (weak) IBOutlet NSTextField *higher809;
@property (weak) IBOutlet NSTextField *higher618;
@property (weak) IBOutlet NSTextField *higher382;
@property (weak) IBOutlet NSTextField *higher191;

@property (weak) IBOutlet NSTextField *highLow191;
@property (weak) IBOutlet NSTextField *highLow382;
@property (weak) IBOutlet NSTextField *highLow618;
@property (weak) IBOutlet NSTextField *highLow809;

@property (weak) IBOutlet NSTextField *lower191;
@property (weak) IBOutlet NSTextField *lower382;
@property (weak) IBOutlet NSTextField *lower618;
@property (weak) IBOutlet NSTextField *lower809;

// Tab 2 - Trend

@property (weak) IBOutlet NSTextField *valueATextField;
@property (weak) IBOutlet NSTextField *valueBTextField;
@property (weak) IBOutlet NSTextField *valueCTextField;
@property (weak) IBOutlet NSTextField *stopTextField;

@property (weak) IBOutlet NSTextField *valueDTextField;
@property (weak) IBOutlet NSTextField *wave2Height;
@property (weak) IBOutlet NSTextField *wave2Back;
@property (weak) IBOutlet NSTextField *wave2BackPercent;
@property (weak) IBOutlet NSTextField *valueDTooltip;
@property (weak) IBOutlet NSTextField *valueDRange;

@property (weak) IBOutlet NSTextField *valueETextField;
@property (weak) IBOutlet NSTextField *wave3Height;
@property (weak) IBOutlet NSTextField *wave3Cost;
@property (weak) IBOutlet NSTextField *wave3Profit;
@property (weak) IBOutlet NSTextField *wave3ProfitPercent;

@property (weak) IBOutlet NSPopUpButton *waveStylePopUpButton;
@property (weak) IBOutlet NSButton *wave5HelpButton;
@property (weak) IBOutlet NSTextField *wave5PreviousLowestTooltip;
@property (weak) IBOutlet NSTextField *wave5PreviousLowestTextField;
@property (weak) IBOutlet NSTextField *valueFTextField;
@property (weak) IBOutlet NSTextField *wave5ValueFRange;
@property (weak) IBOutlet NSTextField *wave5Cost;
@property (weak) IBOutlet NSTextField *wave5Profit;
@property (weak) IBOutlet NSTextField *wave5ProfitPercent;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)runButtonDidClicked:(id)sender
{
    [self runCalculator];
}

- (IBAction)clearButtonDidClicked:(id)sender
{
    [self clearCalculator];
}

- (void)runCalculator
{
    if (self.tabView.selectedTabViewItem == [self.tabView tabViewItemAtIndex:0]) {
        // run gold logic
        CGFloat a = [[self.minTextField stringValue] floatValue];
        CGFloat b = [[self.maxTextField stringValue] floatValue];
        CGFloat lMin = MIN(a, b);
        CGFloat lMax = MAX(a, b);
        
        [self.rangeTextField setStringValue:[NSString stringWithFormat:@"%.f", lMax - lMin]];
        [self.midTextField setStringValue:[NSString stringWithFormat:@"%.2f", (lMax + lMin) / 2]];
        
        [self setHigherGroupValueMin:lMin max:lMax];
        [self setHighToLowGroupValueMin:lMin max:lMax];
        [self setLowerGroupValueMin:lMin max:lMax];
        
    }
    else if (self.tabView.selectedTabViewItem == [self.tabView tabViewItemAtIndex:1]){
        // run wave logic
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary* keys = @{kStockMacPointAKey: @(1),
                                      kStockMacPointBKey: @(2),
                                      kStockMacPointCKey: @(3),
                                      kStockMacPointDKey: @(4),
                                      kStockMacStopKey: @(5),
                                      kStockMacWave4LowestPointKey: @(6)};
        [defaults setObject:keys forKey:kUserDefaultKey];
    }
}

- (void)clearCalculator
{
    if (self.tabView.selectedTabViewItem == [self.tabView tabViewItemAtIndex:0]) {
        // run gold logic
        [self.minTextField setStringValue:@"0"];
        [self.maxTextField setStringValue:@"0"];
        [self.rangeTextField setStringValue:@"0"];
        [self.midTextField setStringValue:@"0"];
        
        [self setHigherGroupValueMin:0 max:0];
        [self setHighToLowGroupValueMin:0 max:0];
        [self setLowerGroupValueMin:0 max:0];
        
    }
    else if (self.tabView.selectedTabViewItem == [self.tabView tabViewItemAtIndex:1]){
        // run wave logic
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"%@", [defaults objectForKey:kUserDefaultKey]);
    }
}

#pragma mark - Run Gold Percent Logic
- (void)setHigherGroupValueMin:(CGFloat)min max:(CGFloat)max
{
    CGFloat lMin = MIN(min, max);
    CGFloat lMax = MAX(min, max);
    CGFloat range = lMax - lMin;
    
    CGFloat lValue191 = lMax + range * kGoldPercent191;
    CGFloat lValue382 = lMax + range * kGoldPercent382;
    CGFloat lValue618 = lMax + range * kGoldPercent618;
    CGFloat lValue809 = lMax + range * kGoldPercent809;
    
    [self.higher191 setStringValue:[NSString stringWithFormat:@"%.2f", lValue191]];
    [self.higher382 setStringValue:[NSString stringWithFormat:@"%.2f", lValue382]];
    [self.higher618 setStringValue:[NSString stringWithFormat:@"%.2f", lValue618]];
    [self.higher809 setStringValue:[NSString stringWithFormat:@"%.2f", lValue809]];
}

- (void)setHighToLowGroupValueMin:(CGFloat)min max:(CGFloat)max
{
    CGFloat lMin = MIN(min, max);
    CGFloat lMax = MAX(min, max);
    CGFloat range = lMax - lMin;
    
    CGFloat lValue191 = lMax - range * kGoldPercent191;
    CGFloat lValue382 = lMax - range * kGoldPercent382;
    CGFloat lValue618 = lMax - range * kGoldPercent618;
    CGFloat lValue809 = lMax - range * kGoldPercent809;
    
    [self.highLow191 setStringValue:[NSString stringWithFormat:@"%.2f", lValue191]];
    [self.highLow382 setStringValue:[NSString stringWithFormat:@"%.2f", lValue382]];
    [self.highLow618 setStringValue:[NSString stringWithFormat:@"%.2f", lValue618]];
    [self.highLow809 setStringValue:[NSString stringWithFormat:@"%.2f", lValue809]];
}

- (void)setLowerGroupValueMin:(CGFloat)min max:(CGFloat)max
{
    CGFloat lMin = MIN(min, max);
    CGFloat lMax = MAX(min, max);
    CGFloat range = lMax - lMin;
    
    CGFloat lValue191 = lMin - range * kGoldPercent191;
    CGFloat lValue382 = lMin - range * kGoldPercent382;
    CGFloat lValue618 = lMin - range * kGoldPercent618;
    CGFloat lValue809 = lMin - range * kGoldPercent809;
    
    [self.lower191 setStringValue:[NSString stringWithFormat:@"%.2f", lValue191]];
    [self.lower382 setStringValue:[NSString stringWithFormat:@"%.2f", lValue382]];
    [self.lower618 setStringValue:[NSString stringWithFormat:@"%.2f", lValue618]];
    [self.lower809 setStringValue:[NSString stringWithFormat:@"%.2f", lValue809]];
}


@end
