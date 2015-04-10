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
    CGFloat _maxHp;
    CGFloat _hp;
    NSArray* _velocity;
    CCTime _fireInterval;
    IntervalScheduler* _fireScheduler;
}

@synthesize fireInterval = _fireInterval;
@synthesize velocity = _velocity;
@synthesize maxHp = _maxHp;
@synthesize hp = _hp;

static const float MIN_HP = 0.0001;

- (void)setVelocity:(NSArray *)velocity{
    _velocity = velocity;
    self.physicsBody.velocity = ccp([_velocity[0] integerValue], [_velocity[1] integerValue]);
}

- (void)setMaxHp:(CGFloat)maxHp{
    _hp = _hp/_maxHp*maxHp;
    _maxHp = maxHp;
}

-(void)setFireInterval:(CCTime)fireInterval{
    _fireInterval = fireInterval;
    if (_fireScheduler == nil) {
        _fireScheduler = [IntervalScheduler getInstance:fireInterval];
    }else{
        [_fireScheduler setInterval:fireInterval];
    }
}

- (void)didLoadFromCCB {
    _maxHp = MIN_HP;
    self.hp = self.maxHp;
}

+ (Plane*)generate:(NSString *)planeFile{
    
    CGSize world = [CCDirector  sharedDirector].viewSize;
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    plane.bullet = [Bullet generate:@"bullet1"];
    plane.maxHp = 99;

    if ([planeFile isEqual:@"hero"]) {
        plane.maxHp = 399;
        plane.position = ccp(world.width/2, world.height/4);
        plane.fireInterval = 0.2f;
        plane.physicsBody.collisionCategories = @[@"hero"];
        plane.physicsBody.collisionType = @"hero";
        plane.physicsBody.collisionMask = @[@"enemy_bullet",@"enemy"];
        
        plane.bullet.velocity = @[@0, @150];
        plane.bullet.physicsBody.collisionCategories=@[@"hero_bullet"];
        plane.bullet.physicsBody.collisionType = @"hero_bullet";
        plane.bullet.physicsBody.collisionMask = @[@"enemy"];
        return plane;
    }
    
    plane.position = ccp((arc4random()%((int)(world.width-plane.contentSize.width)))+plane.contentSize.width/2, world.height);
    plane.velocity = @[@0, @-100];
    plane.fireInterval = 1.f;
    plane.physicsBody.collisionCategories=@[@"enemy"];
    plane.physicsBody.collisionType = @"enemy";
    plane.physicsBody.collisionMask = @[@"hero_bullet",@"hero"];
    
    plane.bullet.velocity = @[@0, @-200];
    plane.bullet.physicsBody.collisionCategories=@[@"enemy_bullet"];
    plane.bullet.physicsBody.collisionType = @"enemy_bullet";
    plane.bullet.physicsBody.collisionMask = @[@"hero"];
    
    
    if ([planeFile isEqual:@"small_plane"]) {
        //plane.maxHp = 99;
    }else if([planeFile isEqual:@"big_plane"]){
        //plane.maxHp = 499;
    }
    return plane;
}

- (BOOL)dead{
    return _hp < MIN_HP;
}

-(void)update:(CCTime)delta{
    if ([self dead]) {
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
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"plane_explosion"];
    explosion.position = self.position;
    [self.parent addChild:explosion];
    explosion.autoRemoveOnFinish = YES;
    [self removeFromParent];
}

- (void)onHitBullet: (Bullet*)bullet{
    self.hp -= bullet.damage;
}

-(void)onHitPlane:(Plane *)plane{
    self.hp -= plane.maxHp;
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
