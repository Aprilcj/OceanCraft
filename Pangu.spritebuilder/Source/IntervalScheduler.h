//
//  IntervalScheduler.h
//  pangu
//
//  Created by April on 3/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntervalScheduler : NSObject
- (BOOL)scheduled:(CCTime) delta;
- (void)setInterval:(CGFloat)interval;
+(id) getInstance:(CCTime) interval;
@end
