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
    IntervalScheduler* _fireScheduler;
    CGPoint _speed;
}

- (void)didLoadFromCCB {
    self.hp = 100;
    self.physicsBody.collisionType=@"plane";
    self.bulletFile = @"bullet1";
    [self setSpeed:ccp(0, -100)];
    _fireScheduler = [IntervalScheduler getInstance:0.2f];
}

-(void)setSpeed:(CGPoint)speed{
    _speed = speed;
    [self.physicsBody setVelocity:_speed];
}

-(void)setFireInterval:(CCTime)fireInterval{
    [_fireScheduler setInterval:fireInterval];
}

+ (Plane*)generate:(NSString *)planeFile{
    CGSize world = [CCDirector  sharedDirector].viewSize;
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    plane.position = ccp((arc4random()%((int)(world.width-plane.contentSize.width)))+plane.contentSize.width/2, world.height);
    plane.bulletFile = nil;
    if ([planeFile isEqual:@"small_plane"]) {
        
    }else if([planeFile isEqual:@"big_plane"]){
        plane.hp = 500;
        
    }
    return plane;
}

-(void)update:(CCTime)delta{
    if (self.hp < 0) {
        [self explode];
        return;
    }
    if (self.position.y < 0) {
        [self removeFromParent];
        return;
    }
    [self fire:delta];
}

- (void)explode{
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    explosion.position = self.position;
    [self.parent addChild:explosion];
    explosion.autoRemoveOnFinish = YES;
    [self removeFromParent];
}

- (void)onHitBullet: (Bullet*)bullet{
    self.hp -= bullet.damage;
}

-(void)onHitPlane:(Plane *)plane{
    self.hp -= plane.hp;
}

-(void)fire:(CCTime)delta{
    if ([_fireScheduler scheduled:delta]) {
        if (self.bulletFile) {
            Bullet* bullet = (Bullet*)[CCBReader load:self.bulletFile];
            bullet.physicsBody.collisionType = [self.physicsBody.collisionType stringByAppendingString:@"_bullet"];
            bullet.position=ccp(self.position.x,self.position.y+self.contentSize.height);
            [[self parent] addChild:bullet];
        }
    }
}

@end
