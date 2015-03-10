//
//  Bullet.m
//  pangu
//
//  Created by April on 3/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet{
    
}

- (void)didLoadFromCCB{
    self.damage = 50;
    self.range = [CCDirector sharedDirector].viewSize.height;
    self.bulletSpeed = ccp(0, 150);
    self.physicsBody.collisionType=@"bullet";
}

-(void)update:(CCTime)delta{
    if (self.position.y > self.range) {
        [self removeFromParent];
        return;
    }
    [self.physicsBody setVelocity:self.bulletSpeed];
}
@end
