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
#import "NSObject+Config.h"
#import "Gameplay.h"

@implementation Plane{
    NSInteger _maxHp;
    NSInteger _hp;
    CGPoint _positionInPercent;
    CCTime _fireInterval;
    IntervalScheduler* _fireScheduler;
}

@synthesize fireInterval = _fireInterval;
@synthesize maxHp = _maxHp;
@synthesize hp = _hp;
@synthesize positionInPercent = _positionInPercent;

static const float MIN_HP = 1;

- (void)setMaxHp:(NSInteger)maxHp{
    if (_maxHp == 0) {
        _hp = maxHp;
    }else{
        _hp = 1.0*_hp/_maxHp*maxHp;
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
}

+ (Plane*)generate:(NSString *)planeFile{
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    [plane loadDefault:planeFile];
    return plane;
}

- (void)loadDefault:(NSString*)file{
    self.file = file;
    CGSize world = [CCDirector  sharedDirector].viewSize;
    
    if ([self.file isEqualToString:TYPE_HERO]) {
        self.maxHp = 500;
        self.position = ccp(world.width/2, world.height/4);
        self.fireInterval = 0.5f;
        self.physicsBody.collisionCategories = @[TYPE_HERO];
        self.physicsBody.collisionType =TYPE_HERO;
        self.physicsBody.collisionMask = @[TYPE_ENEMY_BULLET,TYPE_ENEMY];
        
        self.bullet = [Bullet generate:@"bullet1"];
        self.bullet.physicsBody.velocity = ccp(0, 150);
        self.bullet.physicsBody.collisionCategories=@[TYPE_HERO_BULLET];
        self.bullet.physicsBody.collisionType = TYPE_HERO_BULLET;
        self.bullet.physicsBody.collisionMask = @[TYPE_ENEMY];
        return;
    }
    
    self.bullet = [Bullet generate:@"bullet1"];
    self.maxHp = 100;
    self.position = ccp((arc4random()%((int)(world.width-self.contentSize.width)))+self.contentSize.width/2, world.height);
    self.physicsBody.velocity = ccp(0, -100);
    self.fireInterval = 2.0f;
    self.physicsBody.collisionCategories=@[TYPE_ENEMY];
    self.physicsBody.collisionType = TYPE_ENEMY;
    self.physicsBody.collisionMask = @[TYPE_HERO_BULLET,TYPE_HERO];
    
    self.bullet.physicsBody.velocity = ccp(0, -200);
    self.bullet.physicsBody.collisionCategories=@[TYPE_ENEMY_BULLET];
    self.bullet.physicsBody.collisionType = TYPE_ENEMY_BULLET;
    self.bullet.physicsBody.collisionMask = @[TYPE_HERO];

}

- (BOOL)dead{
    return _hp < MIN_HP;
}

-(void)update:(CCTime)delta{
    if ([self dead]) {
        [self onDead];
        [self explode];
        return;
    }
    if (self.position.y < 0) {
        [self removeFromParent];
        return;
    }
    [self fire:delta];
}

- (void)onDead{
    LOG_FUN;
    NSDictionary* callback = [self.config dictFrom:@[@"onDead"]];
    if (!callback) {
        return;
    }

    Gameplay* gameplay = [Gameplay currentGame];
    NSString* method = [callback stringFrom:@[@"method"]];
    LOG_VAR(method, @"%@");
    
    if ([method isEqualToString:@"changeBullet"]) {
        NSDictionary* newBullet = [callback dictFrom:@[@"newBullet"]];
        [gameplay changeBullet:newBullet];
    }else if([method isEqualToString:@"onMissionComplete"]){
        [gameplay onMissionComplete];
    }
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
