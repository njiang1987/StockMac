//
//  ScaryBugData.h
//  StockMac
//
//  Created by jn11585852 on 14/12/20.
//  Copyright (c) 2014年 JiangNan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaryBugData : NSObject

@property (strong) NSString *title;
@property (assign) float rating;

- (id)initWithTitle:(NSString*)title rating:(float)rating;

@end
