//
//  IntervalScheduler.m
//  pangu
//
//  Created by April on 3/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "IntervalScheduler.h"

@implementation IntervalScheduler{
    CCTime leftTime;
}

+ (id)getInstance:(CCTime)interval{
    IntervalScheduler* scheduler = [[IntervalScheduler alloc] init];
    scheduler.interval = interval;
    return scheduler;
}

- (BOOL)scheduled:(CCTime) delta{
    if (delta < leftTime) {
        leftTime -= delta;
        return NO;
    }
    leftTime += self.interval;
    return YES;
}
@end
