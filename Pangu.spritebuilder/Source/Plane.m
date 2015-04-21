//
//  Penguin.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Plane.h"
#import "Bullet.h"
#import "NSObject+Config.h"
#import "Gameplay.h"

@implementation Plane{
    NSInteger _maxHp;
    NSInteger _hp;
    CGPoint _positionInPercent;
    CCTime _fireInterval;
    CGSize OUT_OF_STAGE;
    NSString* _sailTo;
    CGPoint _direction;
    CGFloat _speed;
}

@synthesize fireInterval = _fireInterval;
@synthesize maxHp = _maxHp;
@synthesize hp = _hp;
@synthesize positionInPercent = _positionInPercent;
@synthesize sailTo = _sailTo;
@synthesize direction = _direction;
@synthesize speed = _speed;

static const NSInteger MIN_HP = 0;
static const CGFloat MIN_UNIT = 0.00001;

- (void)setMaxHp:(NSInteger)maxHp{
    if (_maxHp == 0) {
        _hp = maxHp;
    }else{
        _hp = 1.0*_hp/_maxHp*maxHp;
    }
    _maxHp = maxHp;
}

-(void)setDirection:(CGPoint)direction{
    _direction = direction;
    [self updateVelocity ];
}

-(void)setSpeed:(CGFloat)speed{
    _speed = speed;
    [self updateVelocity ];
}

-(void)updateVelocity{
    if (abs(_direction.x) < MIN_UNIT && abs(_direction.y) < MIN_UNIT) {
        self.physicsBody.velocity = ccp(0, 0);
        return;
    }
    
    CGPoint normalizedDirection = ccpNormalize(_direction);
    self.physicsBody.velocity = ccp(normalizedDirection.x*_speed, normalizedDirection.y*_speed);
}

-(void)setSailTo:(NSString *)sailTo{
    CGPoint beginPosition;
    if ([sailTo isEqualToString:@"up"]) {
        _direction = ccp(0, 1);
    }else if ([sailTo isEqualToString:@"down"]) {
        _direction = ccp(0, -1);
    }else if ([sailTo isEqualToString:@"left"]) {
        _direction = ccp(-1, 0);
    }else if ([sailTo isEqualToString:@"right"]) {
        _direction = ccp(1, 0);
    }else if ([sailTo isEqualToString:@"upLeft"]||[sailTo isEqualToString:@"leftUp"]) {
        _direction = ccp(-1, 1);
    }else if ([sailTo isEqualToString:@"upRight"]||[sailTo isEqualToString:@"rightUp"]) {
        _direction = ccp(1, 1);
    }else if ([sailTo isEqualToString:@"downLeft"]||[sailTo isEqualToString:@"leftDown"]) {
        _direction = ccp(-1, -1);
    }else if ([sailTo isEqualToString:@"downRight"]||[sailTo isEqualToString:@"rightDown"]) {
        _direction = ccp(1, -1);
    }else{
        _direction = ccp(0, 0);
    }
    
    CGSize world = [CCDirector  sharedDirector].viewSize;
    if (_direction.x < -MIN_UNIT) {
        beginPosition.x = world.width + self.contentSize.width/2;
    }else if(_direction.x > MIN_UNIT){
        beginPosition.x = 0 - self.contentSize.width/2;
    }else{
        beginPosition.x =(arc4random()%((int)(world.width-self.contentSize.width)))+self.contentSize.width/2;
    }
    
    if (_direction.y < -MIN_UNIT) {
        beginPosition.y = world.height + self.contentSize.height/2;
    }else if(_direction.y > MIN_UNIT){
        beginPosition.y = 0 - self.contentSize.height/2;
    }else{
        beginPosition.y =(arc4random()%((int)(world.height-self.contentSize.height)))+self.contentSize.height/2;
    }
    
    self.position = beginPosition;
    [self updateVelocity];
}

- (void)setPositionInPercent:(CGPoint)positionInPercent{
    _positionInPercent = positionInPercent;
    CGSize world = [CCDirector  sharedDirector].viewSize;
    self.position = ccp(world.width*_positionInPercent.x, world.height*_positionInPercent.y);
}

-(void)setFireInterval:(CCTime)fireInterval{
    _fireInterval = fireInterval;
    [self schedule:@selector(fire) interval:fireInterval];
}

- (void)didLoadFromCCB {
    CGSize world = [CCDirector  sharedDirector].viewSize;
    OUT_OF_STAGE = CGSizeMake(world.width+self.contentSize.width, world.height + self.contentSize.height);
}

+ (Plane*)generate:(NSString *)planeFile{
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    plane.file = planeFile;
    [plane loadDefault:planeFile];
    return plane;
}

- (void)loadDefault:(NSString*)file{
    CGSize world = [CCDirector  sharedDirector].viewSize;
    self.speed = 100;
    
    // hero
    if ([self.category isEqualToString:TYPE_HERO]) {
        self.maxHp = 500;
        self.position = ccp(world.width/2, world.height/4);
        self.fireInterval = 0.5f;
        self.physicsBody.collisionCategories = @[TYPE_HERO];
        self.physicsBody.collisionType =TYPE_HERO;
        self.physicsBody.collisionMask = @[TYPE_ENEMY_BULLET,TYPE_ENEMY, TYPE_EQUIPMENT];
        
        self.bullet = [Bullet generate:@"bullet1"];
        self.bullet.physicsBody.velocity = ccp(0, 150);
        self.bullet.physicsBody.collisionCategories=@[TYPE_HERO_BULLET];
        self.bullet.physicsBody.collisionType = TYPE_HERO_BULLET;
        self.bullet.physicsBody.collisionMask = @[TYPE_ENEMY];
        return;
    }
    
    //equipment
    if ([self.category isEqualToString:TYPE_EQUIPMENT]) {
        self.maxHp = 0;
        self.sailTo = @"down";
        self.physicsBody.collisionCategories = @[TYPE_EQUIPMENT];
        self.physicsBody.collisionType =TYPE_EQUIPMENT;
        self.physicsBody.collisionMask = @[TYPE_HERO];
        return;
    }
    
    
    //enemy
    self.bullet = [Bullet generate:@"bullet1"];
    self.maxHp = (ccpLength(ccpFromSize(self.contentSize))/55 + 1)*100;
    self.sailTo = @"down";
    self.fireInterval = 3.0f;
    
    self.physicsBody.collisionCategories=@[TYPE_ENEMY];
    self.physicsBody.collisionType = TYPE_ENEMY;
    self.physicsBody.collisionMask = @[TYPE_HERO_BULLET,TYPE_HERO];
    
    self.bullet.physicsBody.velocity = ccp(0, -150);
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
    if (self.position.y < -self.contentSize.height || self.position.x < -self.contentSize.width || self.position.x > OUT_OF_STAGE.width || self.position.y > OUT_OF_STAGE.height) {
        [self removeFromParent];
        return;
    }
}

- (void)onDead{
    Gameplay* gameplay = [Gameplay currentGame];
    [gameplay onHitDown:self];
    
    LOG_FUN;
    NSDictionary* callback = [self.config dictFrom:@[@"onDead"]];
    if (!callback) {
        return;
    }

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

-(void)fire{
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

@end
