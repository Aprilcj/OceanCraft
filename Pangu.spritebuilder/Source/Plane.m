//
//  Penguin.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Plane.h"
#import "IntervalScheduler.h"


@implementation Plane{
    NSMutableArray *_bullets;
    IntervalScheduler* _fireScheduler;
}

- (id)init{
    if (self = [super init]) {
        [self initData];
    }
    return  self;
}

- (void)initData{
    LOG(@"initData", "");
    self.range = 568;
    self.fireInterval = 0.2f;
    self.bulletSpeed = CGVectorMake(0, 25);
    self.bulletFile = @"bullet1";
    self.planeSpeed = CGVectorMake(0, -5);
    _bullets = [NSMutableArray array];
    _fireScheduler = [IntervalScheduler getInstance:self.fireInterval];
}

+ (Plane*)generate:(NSString *)planeFile{
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    return plane;
}

-(void)fire:(CCTime)delta{
    //remove bullets out of boundry
    NSMutableArray *itemsToBeRemoved = [NSMutableArray array];
    for (CCSprite* bullet in _bullets) {
        bullet.position=ccp(bullet.position.x + self.bulletSpeed.dx,bullet.position.y+self.bulletSpeed.dy);
        if (bullet.position.y > self.range) {
            [itemsToBeRemoved addObject:bullet];
        }
    }
    for (CCSprite* bullet in itemsToBeRemoved) {
        [_bullets removeObject:bullet];
        [self.parent removeChild:bullet];
    }
    
    
    if ([_fireScheduler scheduled:delta]) {
        CCSprite* bullet = (CCSprite*)[CCBReader load:self.bulletFile];
        bullet.position=ccp(self.position.x,self.position.y+self.contentSize.height/2);
        [_bullets addObject:bullet];
        [[self parent] addChild:bullet];
    }
}

@end
