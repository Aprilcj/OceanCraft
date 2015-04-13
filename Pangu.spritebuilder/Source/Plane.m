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
    CGPoint _positionInPercent;
    CCTime _fireInterval;
    IntervalScheduler* _fireScheduler;
}

@synthesize fireInterval = _fireInterval;
@synthesize maxHp = _maxHp;
@synthesize hp = _hp;
@synthesize positionInPercent = _positionInPercent;

static const float MIN_HP = 1;

- (void)setMaxHp:(CGFloat)maxHp{
    if (_maxHp == 0) {
        _maxHp = maxHp;
    }else{
        _hp = _hp/_maxHp*maxHp;
    }
    _maxHp = maxHp;
}

- (void)setPositionInPercent:(CGPoint)positionInPercent{
    _positionInPercent = positionInPercent;
    CGSize world = [CCDirector  sharedDirector].viewSize;
    self.position = ccp(world.width*_positionInPercent.x, world.height*_positionInPercent.y);
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
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    [plane loadDefault:planeFile];
    return plane;
}

- (void)loadDefault:(NSString*)file{
    self.file = file;
    CGSize world = [CCDirector  sharedDirector].viewSize;
    self.bullet = [Bullet generate:@"bullet1"];
    self.maxHp = 99;
    
    if ([self.file isEqual:@"hero"]) {
        self.maxHp = 399;
        self.position = ccp(world.width/2, world.height/4);
        self.fireInterval = 0.2f;
        self.physicsBody.collisionCategories = @[@"hero"];
        self.physicsBody.collisionType = @"hero";
        self.physicsBody.collisionMask = @[@"enemy_bullet",@"enemy"];
        
        self.bullet.physicsBody.velocity = ccp(0, 150);
        self.bullet.physicsBody.collisionCategories=@[@"hero_bullet"];
        self.bullet.physicsBody.collisionType = @"hero_bullet";
        self.bullet.physicsBody.collisionMask = @[@"enemy"];
        return;
    }
    
    self.position = ccp((arc4random()%((int)(world.width-self.contentSize.width)))+self.contentSize.width/2, world.height);
    self.physicsBody.velocity = ccp(0, -100);
    self.fireInterval = 1.f;
    self.physicsBody.collisionCategories=@[@"enemy"];
    self.physicsBody.collisionType = @"enemy";
    self.physicsBody.collisionMask = @[@"hero_bullet",@"hero"];
    
    self.bullet.physicsBody.velocity = ccp(0, -200);
    self.bullet.physicsBody.collisionCategories=@[@"enemy_bullet"];
    self.bullet.physicsBody.collisionType = @"enemy_bullet";
    self.bullet.physicsBody.collisionMask = @[@"hero"];
    
    
    if ([self.file isEqual:@"small_plane"]) {
        //plane.maxHp = 99;
    }else if([self.file isEqual:@"big_plane"]){
        //plane.maxHp = 499;
    }

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
        Bullet* bullet = [Bullet duplicate:self.bullet];
        if (bullet) {
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
