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

#define kGoldPercent191     0.191
#define kGoldPercent382     0.382
#define kGoldPercent618     0.618
#define kGoldPercent809     0.809
#define kGoldPercent1618    1.618

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
@property (weak) IBOutlet NSTextField *wave2Height;     // actually it is the first wave
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

@property (readonly) BOOL isAscending;
@property (readonly) CGFloat firstWaveHeight;

@end

@implementation MasterViewController

// the estimated trend
- (BOOL)isAscending
{
    CGFloat valueA = [[self.valueATextField stringValue] floatValue];
    CGFloat valueB = [[self.valueBTextField stringValue] floatValue];
    
    if (valueA < valueB) {
        return NO;
    }
    else{
        return YES;
    }
}

- (CGFloat)firstWaveHeight
{
    CGFloat valueC = [[self.valueCTextField stringValue] floatValue];
    CGFloat valueB = [[self.valueBTextField stringValue] floatValue];
    return fabs(valueB - valueC);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self readRequiredValue];
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
        [self runWaveLogic];
        
        [self storeRequiredValue];
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
        
        [self storeRequiredValue];
    }
}

#pragma mark - Run Trend Logic
- (void)storeRequiredValue
{
    CGFloat valueA = [[self.valueATextField stringValue] floatValue];
    CGFloat valueB = [[self.valueBTextField stringValue] floatValue];
    CGFloat valueC = [[self.valueCTextField stringValue] floatValue];
    CGFloat valueD = [[self.valueDTextField stringValue] floatValue];
    CGFloat valueStop = [[self.stopTextField stringValue] floatValue];
    CGFloat wave4Lowest = [[self.wave5PreviousLowestTextField stringValue] floatValue];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* keys = @{kStockMacPointAKey: @(valueA),
                           kStockMacPointBKey: @(valueB),
                           kStockMacPointCKey: @(valueC),
                           kStockMacPointDKey: @(valueD),
                           kStockMacStopKey: @(valueStop),
                           kStockMacWave4LowestPointKey: @(wave4Lowest)};
    [defaults setObject:keys forKey:kUserDefaultKey];
}

- (NSDictionary*)readRequiredValue
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* lpValues = [defaults objectForKey:kUserDefaultKey];
    
    CGFloat valueA = [[lpValues objectForKey:kStockMacPointAKey] floatValue];
    CGFloat valueB = [[lpValues objectForKey:kStockMacPointBKey] floatValue];
    CGFloat valueC = [[lpValues objectForKey:kStockMacPointCKey] floatValue];
    CGFloat valueD = [[lpValues objectForKey:kStockMacPointDKey] floatValue];
    CGFloat valueStop = [[lpValues objectForKey:kStockMacStopKey] floatValue];
    CGFloat wave4Lowest = [[lpValues objectForKey:kStockMacWave4LowestPointKey] floatValue];
    
    [self.valueATextField setStringValue:[NSString stringWithFormat:@"%.f", valueA]];
    [self.valueBTextField setStringValue:[NSString stringWithFormat:@"%.f", valueB]];
    [self.valueCTextField setStringValue:[NSString stringWithFormat:@"%.f", valueC]];
    [self.valueDTextField setStringValue:[NSString stringWithFormat:@"%.f", valueD]];
    [self.stopTextField setStringValue:[NSString stringWithFormat:@"%.f", valueStop]];
    [self.wave5PreviousLowestTextField setStringValue:[NSString stringWithFormat:@"%.f", wave4Lowest]];
    
    return lpValues;
}

- (void)runWaveLogic
{
    [self handleWave2Logic];
    [self handleWave3Logic];
}

- (void)handleWave2Logic
{
    CGFloat valueA = [[self.valueATextField stringValue] floatValue];
    CGFloat valueB = [[self.valueBTextField stringValue] floatValue];
    CGFloat valueC = [[self.valueCTextField stringValue] floatValue];
    CGFloat valueD = [[self.valueDTextField stringValue] floatValue];
    CGFloat valueStop = [[self.stopTextField stringValue] floatValue];
    CGFloat wave4Lowest = [[self.wave5PreviousLowestTextField stringValue] floatValue];
    
    self.valueDTooltip.hidden = YES;
    self.valueDRange.hidden = YES;
    [self.wave2Height setStringValue:[NSString stringWithFormat:@"%.2f", self.firstWaveHeight]];
    [self.wave2Back setStringValue:@"0"];
    [self.wave2BackPercent setStringValue:@"0"];
    
    if ([[self.valueDTextField stringValue] compare:@"0"]) {
        // only estimate wave 2 logic
        self.valueDTooltip.hidden = NO;
        self.valueDRange.hidden = NO;
        
        NSString* lpTooltip = nil;
        NSString* lpValueDRange = nil;
        if (self.isAscending) {
            lpTooltip = @"D = 40\% ~ 80\%";
            CGFloat min = valueC - self.firstWaveHeight * 0.8;
            CGFloat max = valueC - self.firstWaveHeight * 0.4;
            lpValueDRange = [NSString stringWithFormat:@"%.2f ~ %.2f", min, max];
        }
        else{
            lpTooltip = @"D = 30\% ~ 95\%";
            CGFloat min = valueC + self.firstWaveHeight * 0.95;
            CGFloat max = valueC + self.firstWaveHeight * 0.3;
            lpValueDRange = [NSString stringWithFormat:@"%.2f ~ %.2f", min, max];
        }
        
        [self.valueDTooltip setStringValue:lpTooltip];
        [self.valueDRange setStringValue:lpValueDRange];
    }
    else{
        CGFloat back = fabs(valueD - valueC);
        [self.wave2Back setStringValue:[NSString stringWithFormat:@"%.2f", back]];
        [self.wave2BackPercent setStringValue:[NSString stringWithFormat:@"%.2f", back/self.firstWaveHeight]];
    }
}

- (void)clearWave2Group
{
    self.valueDTooltip.hidden = YES;
    self.valueDRange.hidden = YES;
    [self.wave2Height setStringValue:[NSString stringWithFormat:@"%.2f", self.firstWaveHeight]];
    [self.wave2Back setStringValue:@"0"];
    [self.wave2BackPercent setStringValue:@"0"];
}

- (void)handleWave3Logic
{
    CGFloat valueB = [[self.valueBTextField stringValue] floatValue];
    CGFloat valueC = [[self.valueCTextField stringValue] floatValue];
    CGFloat valueD = [[self.valueDTextField stringValue] floatValue];
    CGFloat valueStop = [[self.stopTextField stringValue] floatValue];
    
    [self.valueETextField setStringValue:@"0"];
    [self.wave3Height setStringValue:@"0"];
    [self.wave3Cost setStringValue:@"0"];
    [self.wave3Profit setStringValue:@"0"];
    [self.wave3ProfitPercent setStringValue:@"0"];
    
    if ([[self.valueDTextField stringValue] compare:@"0"]) {
        return;
    }
    else{
        // calculator target e point
        CGFloat valueE = 0.0f;
        if (self.isAscending) {
            valueE = valueD + kGoldPercent1618 * fabs(valueB - valueC);
        }
        else{
            valueE = valueD - kGoldPercent1618 * fabs(valueB - valueC);
        }
        [self.valueETextField setStringValue:[NSString stringWithFormat:@"%.2f", valueE]];
        [self.wave3Height setStringValue:[NSString stringWithFormat:@"%.2f", kGoldPercent1618 * self.firstWaveHeight]];
        
        // calculator the cost and profit, percent
        CGFloat cost = 0.0f;
        if (self.isAscending) {
            if (valueStop == 0) {
                cost = valueD - valueB;
            }
            else{
                cost = valueD - MIN(valueB, valueStop);
            }
        }
        else{
            if (valueStop == 0) {
                cost = valueB - valueD;
            }
            else{
                cost = valueD - MAX(valueB, valueStop);
            }
        }
        
        CGFloat profit = kGoldPercent1618 * self.firstWaveHeight;
        [self.wave3Cost setStringValue:[NSString stringWithFormat:@"%.2f", cost]];
        [self.wave3Profit setStringValue:[NSString stringWithFormat:@"%.2f", profit]];
        [self.wave3ProfitPercent setStringValue:[NSString stringWithFormat:@"%.2f", profit / cost]];
    }
}

- (void)clearWare3Group
{
    [self.valueETextField setStringValue:@"0"];
    [self.wave3Height setStringValue:@"0"];
    [self.wave3Cost setStringValue:@"0"];
    [self.wave3Profit setStringValue:@"0"];
    [self.wave3ProfitPercent setStringValue:@"0"];
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
