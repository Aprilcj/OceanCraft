//
//  Penguin.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Plane.h"


@implementation Plane{
    NSMutableArray *_bullets;
    CCTime _nextFire;
}

- (id)init {
    if (self = [super init]) {
        self.range = 568;
        self.fireInterval = 0.2f;
        self.bulletSpeed = 25;
        self.bulletName = @"bullet1";
        
        _bullets = [NSMutableArray array];
        _nextFire = 0;
    }
    return  self;
}

-(void)fire:(CCTime)delta{
    NSMutableArray *itemsToBeRemoved = [NSMutableArray array];
    for (CCSprite* bullet in _bullets) {
        bullet.position=ccp(bullet.position.x,bullet.position.y+self.bulletSpeed);
        if (bullet.position.y > self.range) {
            [itemsToBeRemoved addObject:bullet];
        }
    }
    for (CCSprite* bullet in itemsToBeRemoved) {
        [_bullets removeObject:bullet];
        [self.parent removeChild:bullet];
    }
    
    if (delta < _nextFire) {
        _nextFire -= delta;
        return;
    }
    _nextFire = self.fireInterval;
    
    CCSprite* bullet = (CCSprite*)[CCBReader load:self.bulletName];
    bullet.position=ccp(self.position.x,self.position.y+self.contentSize.height/2);
    [_bullets addObject:bullet];
    [[self parent] addChild:bullet];
}

@end
