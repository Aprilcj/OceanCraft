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
}


-(void)setFireInterval:(CCTime)fireInterval{
    if (_fireScheduler == nil) {
        _fireScheduler = [IntervalScheduler getInstance:fireInterval];
    }else{
        [_fireScheduler setInterval:fireInterval];
    }
}

+ (Plane*)generate:(NSString *)planeFile{
    
    CGSize world = [CCDirector  sharedDirector].viewSize;
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    plane.bullet = [Bullet generate:@"bullet1"];
    
    if ([planeFile isEqual:@"hero"]) {
        plane.position = ccp(world.width/2, world.height/4);
        plane.physicsBody.collisionType = @"hero";
        plane.physicsBody.collisionMask = @[@"enemy_bullet",@"enemy"];
        plane.maxHp = 300;
        plane.hp = plane.maxHp;
        [plane setFireInterval:0.2f];

        plane.bullet.physicsBody.velocity = ccp(0, 150);
        plane.bullet.physicsBody.collisionType = @"hero_bullet";
        plane.bullet.physicsBody.collisionMask = @[@"enemy"];
        return plane;
    }

    plane.position = ccp((arc4random()%((int)(world.width-plane.contentSize.width)))+plane.contentSize.width/2, world.height);
    [plane.physicsBody setVelocity:ccp(0, -100)];
    plane.physicsBody.collisionType = @"enemy";
    plane.physicsBody.collisionMask = @[@"hero_bullet",@"hero"];
    plane.bullet.physicsBody.velocity = ccp(0, -200);
    plane.bullet.physicsBody.collisionType = @"enemy_bullet";
    plane.bullet.physicsBody.collisionMask = @[@"hero"];
    [plane setFireInterval:1.f];
    
    if ([planeFile isEqual:@"small_plane"]) {
        plane.maxHp = 99;
    }else if([planeFile isEqual:@"big_plane"]){
        plane.maxHp = 499;
    }
    plane.hp = plane.maxHp;
    return plane;
}

-(void)update:(CCTime)delta{
    if (self.hp < 0) {
        [self explode];
        return;
    }
    if (self.position.y < 0) {
//        [self removeFromParent];
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
        if (self.bullet) {            
            Bullet* bullet = [Bullet duplicate:self.bullet];
            if (self.bullet.physicsBody.velocity.y > 0) {
                bullet.position=ccp(self.position.x,self.position.y+self.contentSize.height/2+bullet.contentSize.height);
            }else{
                bullet.position=ccp(self.position.x,self.position.y-self.contentSize.height/2-bullet.contentSize.height);
                
            }
            [[self parent] addChild:bullet];
        }
    }
}

@end
