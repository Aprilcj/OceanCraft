//
//  Penguin.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Plane.h"
#import "IntervalScheduler.h"
#import "Bullet.h"

@implementation Plane{
    NSMutableArray *_bullets;
    IntervalScheduler* _fireScheduler;
}

- (void)didLoadFromCCB {
    self.range = [CCDirector sharedDirector].viewSize.height;
    self.fireInterval = 0.2f;
    self.bulletSpeed = ccp(0, 150);
    self.bulletFile = @"bullet1";
    self.planeSpeed = CGVectorMake(0, -5);
    _bullets = [NSMutableArray array];
    self.physicsBody.collisionType=@"plane";
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
//        bullet.position=ccp(bullet.position.x + self.bulletSpeed.dx,bullet.position.y+self.bulletSpeed.dy);
        if (bullet.position.y > self.range) {
            [itemsToBeRemoved addObject:bullet];
        }
    }
    for (CCSprite* bullet in itemsToBeRemoved) {
        [_bullets removeObject:bullet];
        [bullet removeFromParent];
    }
    
    
    if ([_fireScheduler scheduled:delta]) {
        Bullet* bullet = (Bullet*)[CCBReader load:self.bulletFile];
        bullet.position=ccp(self.position.x,self.position.y+self.contentSize.height);
        [_bullets addObject:bullet];
        [[self parent] addChild:bullet];
        [bullet.physicsBody setVelocity:self.bulletSpeed];
//        [bullet.physicsBody applyImpulse:self.bulletSpeed];
    }
}

@end
