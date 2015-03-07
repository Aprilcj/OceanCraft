//
//  IntervalScheduler.h
//  pangu
//
//  Created by April on 3/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntervalScheduler : NSObject
@property(nonatomic, assign) CGFloat interval;
- (BOOL)scheduled:(CCTime) delta;
+(id) getInstance:(CCTime) interval;
@end
