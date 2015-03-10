//
//  IntervalScheduler.m
//  pangu
//
//  Created by April on 3/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "IntervalScheduler.h"

@implementation IntervalScheduler{
    CCTime _leftTime;
    CCTime _interval;
}

+ (id)getInstance:(CCTime)interval{
    IntervalScheduler* scheduler = [[IntervalScheduler alloc] init];
    [scheduler setInterval:interval];
    return scheduler;
}

- (void)setInterval:(CGFloat)interval{
    _interval = interval;
    _leftTime = 0;
}

- (BOOL)scheduled:(CCTime) delta{
    if (delta < _leftTime) {
        _leftTime -= delta;
        return NO;
    }
    _leftTime += _interval;
    return YES;
}
@end
