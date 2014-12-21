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
#define kGoldPercent3236    3.236

static NSString* kStockMacPointAKey = @"StockMac.A";
static NSString* kStockMacPointBKey = @"StockMac.B";
static NSString* kStockMacPointCKey = @"SotckMac.C";
static NSString* kStockMacPointDKey = @"StockMac.D";
static NSString* kStockMacPointEKey = @"StockMac.E";
static NSString* kStockMacPointFKey = @"StockMac.F";
static NSString* kStockMacStopKey   = @"StockMac.Stop";
static NSString* kStockMacWaveStyleKey = @"StockMac.WaveStyle";
static NSString* kUserDefaultKey = @"StockMac";

@interface MasterViewController ()

// General view
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSScrollView *trendContentView;

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
@property (weak) IBOutlet NSTextField *stopValueTextField;

// the second wave group
@property (weak) IBOutlet NSTextField *valueDTextField;
@property (weak) IBOutlet NSTextField *wave2Height;     // actually it is the first wave
@property (weak) IBOutlet NSTextField *wave2Back;
@property (weak) IBOutlet NSTextField *wave2BackPercent;
@property (weak) IBOutlet NSTextField *valueDTooltip;
@property (weak) IBOutlet NSTextField *valueDRange;

// the third wave group
@property (weak) IBOutlet NSTextField *valueETextField;
@property (weak) IBOutlet NSTextField *wave3Height;
@property (weak) IBOutlet NSTextField *wave3Cost;
@property (weak) IBOutlet NSTextField *wave3Profit;
@property (weak) IBOutlet NSTextField *wave3ProfitPercent;

// the forth wave group
@property (weak) IBOutlet NSTextField *valueFTextField;
@property (weak) IBOutlet NSTextField *wave4Tooltip;
@property (weak) IBOutlet NSTextField *wave4Back;

// the fifth wave group
@property (weak) IBOutlet NSTextField *valueGTextField;
@property (weak) IBOutlet NSPopUpButton *waveStylePopUpButton;
@property (weak) IBOutlet NSButton *wave5HelpButton;
@property (weak) IBOutlet NSTextField *wave5Cost;
@property (weak) IBOutlet NSTextField *wave5Profit;
@property (weak) IBOutlet NSTextField *wave5ProfitPercent;
@property (weak) IBOutlet NSTextField *wave5ValueGRange;

// logic related
@property (readonly) BOOL isAscending;
@property (readonly) CGFloat firstWaveHeight;
@property (assign) CGFloat valueA;
@property (assign) CGFloat valueB;
@property (assign) CGFloat valueC;
@property (assign) CGFloat valueD;
@property (assign) CGFloat valueE;
@property (assign) CGFloat valueF;
@property (assign) CGFloat stopValue;
@property (assign) NSInteger waveStyle;

@end

@implementation MasterViewController

#pragma mark - Logic Related
- (CGFloat)valueA
{
    return [[self.valueATextField stringValue] floatValue];
}

- (void)setValueA:(CGFloat)valueA
{
    [self.valueATextField setStringValue:[NSString stringWithFormat:@"%.f", valueA]];
}

- (CGFloat)valueB
{
    return [[self.valueBTextField stringValue] floatValue];
}

- (void)setValueB:(CGFloat)valueB
{
    [self.valueBTextField setStringValue:[NSString stringWithFormat:@"%.f", valueB]];
}

- (CGFloat)valueC
{
    return [[self.valueCTextField stringValue] floatValue];
}

- (void)setValueC:(CGFloat)valueC
{
    [self.valueCTextField setStringValue:[NSString stringWithFormat:@"%.f", valueC]];
}

- (CGFloat)valueD
{
    return [[self.valueDTextField stringValue] floatValue];
}

- (void)setValueD:(CGFloat)valueD
{
    [self.valueDTextField setStringValue:[NSString stringWithFormat:@"%.f", valueD]];
}

- (CGFloat)valueE
{
    return [[self.valueETextField stringValue] floatValue];
}

- (void)setValueE:(CGFloat)valueE
{
    [self.valueETextField setStringValue:[NSString stringWithFormat:@"%.f", valueE]];
}

- (CGFloat)valueF
{
    return [[self.valueFTextField stringValue] floatValue];
}

- (void)setValueF:(CGFloat)valueF
{
    [self.valueFTextField setStringValue:[NSString stringWithFormat:@"%.f", valueF]];
}

- (CGFloat)stopValue
{
    return [[self.stopValueTextField stringValue] floatValue];
}

- (void)setStopValue:(CGFloat)stopValue
{
    [self.stopValueTextField setStringValue:[NSString stringWithFormat:@"%.f", stopValue]];
}

/**
 *  Style:
 *  1. The Wave 3 is extension
 *  2. The Wave 5 is extension
 */
- (NSInteger)waveStyle
{
    return (NSInteger)[self.waveStylePopUpButton indexOfItem:self.waveStylePopUpButton.selectedItem];
}

/**
 *  Currently only support 2 types wave style
 */
- (void)setWaveStyle:(NSInteger)waveStyle
{
    if (waveStyle > 2) {
        return;
    }
    [self.waveStylePopUpButton selectItemAtIndex:waveStyle];
}

// the estimated trend
- (BOOL)isAscending
{
    if (self.valueA < self.valueB) {
        return NO;
    }
    else{
        return YES;
    }
}

- (CGFloat)firstWaveHeight
{
    return fabs(self.valueB - self.valueC);
}

#pragma mark - View Related

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
    CGFloat valueA = self.valueA;
    CGFloat valueB = self.valueB;
    CGFloat valueC = self.valueC;
    CGFloat valueD = self.valueD;
    CGFloat valueE = self.valueE;
    CGFloat valueF = self.valueF;
    CGFloat stopValue = self.stopValue;
    CGFloat waveStyle = [self.waveStylePopUpButton indexOfItem:self.waveStylePopUpButton.selectedItem];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* keys = @{kStockMacPointAKey: @(valueA),
                           kStockMacPointBKey: @(valueB),
                           kStockMacPointCKey: @(valueC),
                           kStockMacPointDKey: @(valueD),
                           kStockMacPointEKey: @(valueE),
                           kStockMacPointFKey: @(valueF),
                           kStockMacStopKey: @(stopValue),
                           kStockMacWaveStyleKey: @(waveStyle)};
    [defaults setObject:keys forKey:kUserDefaultKey];
}

- (NSDictionary*)readRequiredValue
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* lpValues = [defaults objectForKey:kUserDefaultKey];
    
    self.valueA = [[lpValues objectForKey:kStockMacPointAKey] floatValue];
    self.valueB = [[lpValues objectForKey:kStockMacPointBKey] floatValue];
    self.valueC = [[lpValues objectForKey:kStockMacPointCKey] floatValue];
    self.valueD = [[lpValues objectForKey:kStockMacPointDKey] floatValue];
    self.valueE = [[lpValues objectForKey:kStockMacPointEKey] floatValue];
    self.valueF = [[lpValues objectForKey:kStockMacPointFKey] floatValue];
    self.stopValue = [[lpValues objectForKey:kStockMacStopKey] floatValue];
    [self.waveStylePopUpButton selectItemAtIndex:[[lpValues objectForKey:kStockMacWaveStyleKey] integerValue]];
    
    return lpValues;
}

- (void)runWaveLogic
{
    [self handleWave2Logic];
    [self handleWave3Logic];
    [self handleWave4Logic];
    [self handleWave5Logic];
}

- (void)handleWave2Logic
{
    [self.wave2Height setStringValue:[NSString stringWithFormat:@"%.2f", self.firstWaveHeight]];
    [self.wave2Back setStringValue:@"0"];
    [self.wave2BackPercent setStringValue:@"0"];
    
    if (self.valueC == 0) {
        self.valueD = 0;
        return;
    }
    
    NSString* lpTooltip = nil;
    if (self.isAscending) {
        lpTooltip = @"D = 40\% ~ 80\%";
    }
    else{
        lpTooltip = @"D = 30\% ~ 95\%";
    }
    [self.valueDTooltip setStringValue:lpTooltip];

    if (self.valueD == 0) {
        // only estimate wave 2 logic
        NSString* lpValueDRange = nil;
        if (self.isAscending) {
            CGFloat min = self.valueC - self.firstWaveHeight * 0.8;
            CGFloat max = self.valueC - self.firstWaveHeight * 0.4;
            lpValueDRange = [NSString stringWithFormat:@"%.2f ~ %.2f", min, max];
        }
        else{
            CGFloat min = self.valueC + self.firstWaveHeight * 0.95;
            CGFloat max = self.valueC + self.firstWaveHeight * 0.3;
            lpValueDRange = [NSString stringWithFormat:@"%.2f ~ %.2f", min, max];
        }
        
        [self.valueDRange setStringValue:lpValueDRange];
    }
    else{
        CGFloat back = fabs(self.valueD - self.valueC);
        [self.wave2Back setStringValue:[NSString stringWithFormat:@"%.2f", back]];
        [self.wave2BackPercent setStringValue:[NSString stringWithFormat:@"%.f%%", back/self.firstWaveHeight * 100]];
        [self.valueDRange setStringValue:[NSString stringWithFormat:@"%.f%%", back/self.firstWaveHeight * 100]];
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
    [self.wave3Height setStringValue:@"0"];
    [self.wave3Cost setStringValue:@"0"];
    [self.wave3Profit setStringValue:@"0"];
    [self.wave3ProfitPercent setStringValue:@"0"];
    
    if (self.valueD == 0) {
        self.valueE = 0;
        return;
    }

    
    if (self.valueE == 0) {
        // calculator target e point
        if (self.isAscending) {
            self.valueE = self.valueD + kGoldPercent1618 * fabs(self.valueB - self.valueC);
        }
        else{
            self.valueE = self.valueD - kGoldPercent1618 * fabs(self.valueB - self.valueC);
        }
    }
    
    [self.wave3Height setStringValue:[NSString stringWithFormat:@"%.2f", kGoldPercent1618 * self.firstWaveHeight]];
    
    // calculator the cost and profit, percent
    CGFloat cost = 0.0f;
    if (self.isAscending) {
        if (self.stopValue == 0) {
            cost = self.valueD - self.valueB;
        }
        else{
            cost = self.valueD - MIN(self.valueB, self.stopValue);
        }
    }
    else{
        if (self.stopValue == 0) {
            cost = self.valueB - self.valueD;
        }
        else{
            cost = self.valueD - MAX(self.valueB, self.stopValue);
        }
    }
    
    CGFloat profit = kGoldPercent1618 * self.firstWaveHeight;
    [self.wave3Cost setStringValue:[NSString stringWithFormat:@"%.2f", cost]];
    [self.wave3Profit setStringValue:[NSString stringWithFormat:@"%.2f", profit]];
    [self.wave3ProfitPercent setStringValue:[NSString stringWithFormat:@"%.2f", profit / cost]];
}

- (void)clearWare3Group
{
    [self.valueETextField setStringValue:@"0"];
    [self.wave3Height setStringValue:@"0"];
    [self.wave3Cost setStringValue:@"0"];
    [self.wave3Profit setStringValue:@"0"];
    [self.wave3ProfitPercent setStringValue:@"0"];
}

- (void)handleWave4Logic
{
    [self.wave4Back setStringValue:@"0"];
    
    if (self.valueE == 0) {
        self.valueF = 0;
        return;
    }
    
    // calculate the back height
    CGFloat wave3Height = fabs(self.valueE - self.valueD);
    if (self.valueF == 0) {
        CGFloat min = 0;
        CGFloat max = 0;
        if (self.isAscending) {
            min = self.valueE - wave3Height * 0.7;
            max = self.valueE - wave3Height * 0.3;
        }
        else{
            min = self.valueE + wave3Height * 0.3;
            max = self.valueE + wave3Height * 0.7;
        }
        
        [self.wave4Back setStringValue:[NSString stringWithFormat:@"%.f | %.f", min, max]];
    }
    else{
        CGFloat back = fabs(self.valueF - self.valueE);
        [self.wave4Back setStringValue:[NSString stringWithFormat:@"%.f (%.f%%)", back, back / wave3Height * 100]];
    }
}

- (void)clearWave4Group
{
    self.valueF = 0;
    [self.wave4Back setStringValue:@"0"];
}

- (void)handleWave5Logic
{
    [self.valueGTextField setStringValue:@"0"];
    [self.wave5Cost setStringValue:@"0"];
    [self.wave5Profit setStringValue:@"0"];
    [self.wave5ValueGRange setStringValue:@"0"];
    [self.wave5ProfitPercent setStringValue:@"0"];
    
    if (self.valueF == 0) {
        return;
    }
    
    // these 2 values stands for no wave style min and max value for G
    CGFloat lNormalMin = 0.0f;
    CGFloat lNormalMax = 0.0f;
    if (self.isAscending) {
        lNormalMin = self.valueB + kGoldPercent3236 * self.firstWaveHeight;
        lNormalMax = self.valueC + kGoldPercent3236 * self.firstWaveHeight;
    }
    else{
        lNormalMax = self.valueB - kGoldPercent3236 * self.firstWaveHeight;
        lNormalMin = self.valueC - kGoldPercent3236 * self.firstWaveHeight;
    }
    
    CGFloat lSpecialMin = 0.0f;
    CGFloat lSpecialMax = 0.0f;
    // not setting wave style, so here we only calculate min and max G value
    if (self.waveStyle == 1) {
        if (self.isAscending) {
            lSpecialMin = self.valueF + kGoldPercent618 * self.firstWaveHeight;
            lSpecialMax = self.valueF + self.firstWaveHeight;
        }
        else{
            lSpecialMin = self.valueF - self.firstWaveHeight;
            lSpecialMax = self.valueF - kGoldPercent618 * self.firstWaveHeight;
        }
    }
    else if(self.waveStyle == 2){
        if (self.isAscending) {
            lSpecialMin = self.valueF + kGoldPercent1618 * (self.valueE - self.valueB);
            lSpecialMax = lSpecialMin;
        }
    }
    
    CGFloat lFinalMin = (lSpecialMin == 0) ? lNormalMin : MIN(lSpecialMin, lNormalMin);
    CGFloat lFinalMax = (lSpecialMax == 0) ? lNormalMax : MAX(lSpecialMax, lNormalMax);
    [self.wave5ValueGRange setStringValue:[NSString stringWithFormat:@"[%.f, %.f]", lFinalMin, lFinalMax]];
    [self.valueGTextField setStringValue:[NSString stringWithFormat:@"%.f", (lFinalMax + lFinalMin) / 2.0]];
    
    // calculate the max loss
    CGFloat lMaxLoss = 0.0f;
    CGFloat lMinProfit = 0.0f;
    if (self.isAscending) {
        lMinProfit = lFinalMin - self.valueF;
        lMaxLoss = self.valueF - MIN(self.stopValue, self.valueB);
    }
    else{
        lMinProfit = self.valueF - lFinalMax;
        lMaxLoss = MAX(self.stopValue, self.valueB) - self.valueF;
    }
    
    [self.wave5Cost setStringValue:[NSString stringWithFormat:@"%.f", lMaxLoss]];
    [self.wave5Profit setStringValue:[NSString stringWithFormat:@"%.f", lMinProfit]];
    [self.wave5ProfitPercent setStringValue:[NSString stringWithFormat:@"%.2f", lMinProfit/lMaxLoss]];
}

- (void)clearWave5Group
{
    [self.valueGTextField setStringValue:@"0"];
    [self.wave5Cost setStringValue:@"0"];
    [self.wave5Profit setStringValue:@"0"];
    [self.wave5ValueGRange setStringValue:@"0"];
    [self.wave5ProfitPercent setStringValue:@"0"];
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

#pragma mark - NSTextFieldDelegate
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    id lpControl = [obj object];
    if (lpControl == self.valueBTextField) {
        NSString* lpValueB = [self.valueBTextField stringValue];
        self.stopValue = [lpValueB floatValue];
    }
}


@end
