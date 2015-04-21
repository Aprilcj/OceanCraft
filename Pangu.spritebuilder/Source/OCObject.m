//
//  Penguin.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "OCObject.h"
#import "NSObject+Config.h"
#import "Gameplay.h"

@implementation OCObject{
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

#pragma mark setters

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

#pragma mark init
- (void)didLoadFromCCB {
    CGSize world = [CCDirector  sharedDirector].viewSize;
    OUT_OF_STAGE = CGSizeMake(world.width+self.contentSize.width, world.height + self.contentSize.height);
}

+ (OCObject*)generate:(NSString *)planeFile{
    OCObject* plane = (OCObject*)[CCBReader load:planeFile];
    plane.file = planeFile;
    [plane loadDefault:planeFile];
    return plane;
}

+ (OCObject*)generate:(NSString *)planeFile category:(NSString*)category{
    OCObject* plane = (OCObject*)[CCBReader load:planeFile];
    plane.file = planeFile;
    plane.category = category;
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
        self.explosionEffect = @"plane_explosion";
        self.bullet = [OCObject generate:@"bullet1" category: TYPE_HERO_BULLET];
        self.physicsBody.collisionCategories = @[TYPE_HERO];
        self.physicsBody.collisionType =TYPE_HERO;
        self.physicsBody.collisionMask = @[TYPE_ENEMY_BULLET,TYPE_ENEMY, TYPE_EQUIPMENT];
        return;
    }
    
    //hero's bullet
    if ([self.category isEqualToString:TYPE_HERO_BULLET]) {
        self.sailTo = @"up";
        self.maxHp = 100;
        self.physicsBody.collisionCategories=@[TYPE_HERO_BULLET];
        self.physicsBody.collisionType = TYPE_HERO_BULLET;
        self.physicsBody.collisionMask = @[TYPE_ENEMY, TYPE_ENEMY_BULLET];
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
    
    // enemy's bullet
    if ([self.category isEqualToString:TYPE_ENEMY_BULLET]) {
        self.speed = 150;
        self.maxHp = 100;
        self.sailTo=@"down";
        self.physicsBody.collisionCategories=@[TYPE_ENEMY_BULLET];
        self.physicsBody.collisionType = TYPE_ENEMY_BULLET;
        self.physicsBody.collisionMask = @[TYPE_HERO, TYPE_HERO_BULLET];
        return;
    }
    
    //enemy
    self.maxHp = (ccpLength(ccpFromSize(self.contentSize))/55 + 1)*100;
    self.sailTo = @"down";
    self.fireInterval = 3.0f;
    self.explosionEffect = @"plane_explosion";
    self.bullet = self.bullet = [OCObject generate:@"bullet1" category: TYPE_ENEMY_BULLET];
    self.physicsBody.collisionCategories=@[TYPE_ENEMY];
    self.physicsBody.collisionType = TYPE_ENEMY;
    self.physicsBody.collisionMask = @[TYPE_HERO_BULLET,TYPE_HERO];
}

+ (OCObject*)duplicate:(OCObject *)bullet{
    if (!bullet.file || bullet.file.length == 0) {
        return nil;
    }
    OCObject* newBullet = [OCObject generate:bullet.file category:bullet.category];
    newBullet.speed = bullet.speed;
    newBullet.direction = bullet.direction;
    newBullet.physicsBody.velocity = bullet.physicsBody.velocity;
    newBullet.physicsBody.collisionType = bullet.physicsBody.collisionType;
    newBullet.physicsBody.collisionMask = bullet.physicsBody.collisionMask;
    return newBullet;
}

#pragma mark update

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

#pragma mark event

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
    if (self.explosionEffect) {
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:self.explosionEffect];
        explosion.position = self.position;
        [self.parent addChild:explosion];
        explosion.autoRemoveOnFinish = YES;
    }
    [self removeFromParent];
}

-(void)onHitPlane:(OCObject *)plane{
    self.hp -= plane.maxHp;
}

-(void)fire{
    OCObject* bullet = [OCObject duplicate:self.bullet];
    if (bullet) {
        if (self.bullet.physicsBody.velocity.y > MIN_UNIT) {
            bullet.position=ccp(self.position.x,self.position.y+self.contentSize.height/2+bullet.contentSize.height);
        }else if (self.bullet.physicsBody.velocity.y < -MIN_UNIT){
            bullet.position=ccp(self.position.x,self.position.y-self.contentSize.height/2-bullet.contentSize.height);
            
        }
        [[self parent] addChild:bullet];
    }
}

@end
