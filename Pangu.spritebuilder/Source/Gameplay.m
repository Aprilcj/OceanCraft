//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "cocos2d.h"
#import "ScriptLoader.h"
#import "NSObject+Config.h"
#import "MainScene.h"

static const float scrollSpeed = -50.f;


@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    
    // score
    CCLabelTTF *_score;
    int _scoreValue;
    
    // hero
    OCObject *_hero;
    
    // background
    CCNode *_bg1;
    CCNode *_bg2;
    NSArray *_bgs;
    
    // retry
    CCButton *_retryButton;
    
    // lifebar
    CCSprite *_lifebar_fill;
    CCProgressNode *_lifeIndicator;
    CCNode* _lifebar_bg;
    CCNode* _lifebar_container;
    
    ScriptLoader* _currentScript;
    NSInteger _currentLevel;
    NSUInteger _currentActor;
}

static Gameplay* s_currentGame;

+ (Gameplay*)currentGame{
    return s_currentGame;
}

#pragma mark init
- (void)didLoadFromCCB {
    s_currentGame = self;
    
    //_physicsNode.debugDraw = YES;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    _physicsNode.physicsBody.collisionMask=@[];
    
    //background
    _bgs = @[_bg1, _bg2];
    for (CCNode* bg in _bgs) {
        [bg.physicsBody setVelocity:ccp(0, scrollSpeed)];
        bg.physicsBody.collisionMask = @[];
    }
    
    // hero
    _hero = [OCObject generate:@"hero" category:TYPE_HERO];
    [_physicsNode addChild:_hero];
    
    //lifebar
    [self addLifeIndicator];
    
    //actors
    _currentScript = [ScriptLoader loaderOfLevel:[MainScene level]];
    _currentActor = 0;
    [self addRoles];
}

- (void) addRoles{
    NSArray* actors = [_currentScript.script arrayFrom:@[@"actors"]];
    if (_currentActor > [actors count] - 1) {
        LOG(@"script over", nil);
        return;
    }
    LOG(@"load actor: %ld", _currentActor);
    NSDictionary* actor =  [actors dictFrom:@[[NSNumber numberWithUnsignedInteger:_currentActor++]]];
    NSArray* roles = [actor arrayFrom:@[@"roles"]];
    
    [self scheduleBlock:^(CCTimer* timer){
        for (NSDictionary* role in roles) {
            NSString* name = [role stringFrom:@[@"name"]];
            NSString* category = [role stringFrom:@[@"category"]];
            NSDictionary* properties = [role dictFrom:@[@"properties"]];
            
            OCObject* object = (OCObject*)[OCObject generate:name category:category];
            if (object == nil) {
                LOG(@"failed to generate object, name = %@", name);
                continue;
            }
            object.config = role;
            if (properties){
                [object setProperties:properties];
            }
            [_hero.parent addChild:object];
            
        }
        [self addRoles];
    } delay:[actor doubleFrom:@[@"delay"]]];
    
}


- (void)addLifeIndicator{
    _lifeIndicator = [CCProgressNode progressWithSprite:_lifebar_fill];
    _lifeIndicator.type = CCProgressNodeTypeBar;
    _lifeIndicator.midpoint = ccp(0.0f, 0.0f);
    _lifeIndicator.barChangeRate = ccp(1.0f, 0.0f);
    _lifeIndicator.percentage = 100.0f;
    
    _lifeIndicator.positionType = _lifebar_bg.positionType;
    _lifeIndicator.anchorPoint = _lifebar_bg.anchorPoint;
    _lifeIndicator.position = _lifebar_bg.position;
    [_lifebar_bg.parent addChild:_lifeIndicator];
}

#pragma mark touch

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchFrom = [touch previousLocationInView:[touch view]];
    CGPoint touchTo = [touch locationInView:[touch view]];
    CGPoint offset = ccpSub(touchTo, touchFrom);
    offset.y = - offset.y;//I don't know why
    CGPoint targetFrom = [_hero position];
    CGPoint targetTo = ccpAdd(targetFrom, ccp(offset.x, offset.y));
    
    float xMin = _hero.contentSize.width/2;
    float xMax = _bg1.contentSize.width-xMin;
    float yMin = _hero.contentSize.height/2;
    float yMax = _bg1.contentSize.height - yMin;
    if (targetTo.x < xMin) {
        targetTo.x = xMin;
    }
    if (targetTo.x > xMax) {
        targetTo.x = xMax;
    }
    if (targetTo.y < yMin) {
        targetTo.y = yMin;
    }
    if (targetTo.y > yMax) {
        targetTo.y = yMax;
    }
    [_hero setPosition:targetTo];
    
}

#pragma mark collision
-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair hero_bullet:(OCObject *)hero_bullet enemy_bullet:(OCObject *)enemy_bullet{
    [[_physicsNode space] addPostStepBlock:^{
        LOG_FUN;
        [hero_bullet explode];
        [enemy_bullet explode];
    } key:hero_bullet];
    return NO;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair hero:(OCObject *)hero enemy_bullet:(OCObject *)enemy_bullet
{
    [[_physicsNode space] addPostStepBlock:^{
        LOG_FUN;
        [hero onHit:enemy_bullet];
        [enemy_bullet explode];
        hero.physicsBody.velocity = ccp(0, 0);
    } key:hero];
    return NO;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair enemy:(OCObject *)enemy hero_bullet:(OCObject *)hero_bullet
{
    [[_physicsNode space] addPostStepBlock:^{
        LOG_FUN;
        [enemy onHit:hero_bullet];
        [hero_bullet explode];
        if (_hero.lifeStealRate > MIN_UNIT) {
            _hero.hp += _hero.lifeStealRate*enemy.maxHp;
        }
    } key:enemy];
    return NO;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair hero:(OCObject *)hero enemy:(OCObject *)enemy
{
    [_physicsNode.space addPostStepBlock:^{
        LOG_FUN;
        [hero onHit:enemy];
        [enemy onHit:hero];
        hero.physicsBody.velocity = ccp(0, 0);
    } key:hero];
    return NO;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair hero:(OCObject *)hero equipment:(OCObject *)equipment
{
    [[_physicsNode space] addPostStepBlock:^{
        LOG_FUN;
        [equipment onHit:hero];
        [hero onHit:equipment];
        hero.physicsBody.velocity = ccp(0, 0);
    } key:hero];
    return NO;
}

#pragma mark on event

-(void)onHitDown: (OCObject*)plane{
    if ([plane isEqual:_hero]) {
        return;
    }
    _scoreValue += plane.maxHp;
    _score.string = [NSString stringWithFormat:@"%d", _scoreValue];
}

-(void)changeBulletTo:(NSDictionary*)newBullet{
    [_hero.bullet setProperties:newBullet];
}

-(void)addLifeBy:(NSInteger)value{
    _hero.hp = MIN(_hero.hp + value, _hero.maxHp);
}

-(void)changeFireIntervalTo:(CGFloat)value{
    _hero.fireInterval = value;
}

-(void)changeDamageTo:(NSInteger)value{
    _hero.bullet.maxHp = value;
}

-(void)forkBullet:(NSInteger)value{
    if (value) {
        _hero.bullet.forkable = YES;
    }else{
        _hero.bullet.forkable = NO;
    }
}

-(void)lifeSteal:(CGFloat)value{
    _hero.lifeStealRate = value;
}

-(void)damageRate:(CGFloat)value{
    _hero.damageRate = value;
}

-(void)completeMission{
    LOG_FUN;
    [self scheduleBlock:^(CCTimer* cctimer){
        if ([_hero dead]) {
            return;
        }
        [MainScene setUnlockedLevel:[MainScene level] + 1];
        CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
        [[CCDirector sharedDirector] replaceScene:mainScene withTransition:[CCTransition transitionFadeWithDuration:1]];
    }delay:3];
}

-(void)onGameOver{
    _retryButton.visible = YES;
}

- (void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"] withTransition:[CCTransition transitionFadeWithDuration:1]];
}

#pragma mark update

- (void)updateBackground
{
    for (CCNode* bg in _bgs) {
        if (bg.position.y <= -bg.contentSize.height) {
            //LOG(@"_bgRect=(%f, %f)", _bgRect.width, _bgRect.height);
            bg.position = ccp(bg.position.x, bg.position.y+2*bg.contentSize.height);
        }
    }
}

- (void)updateLifeIndicator{
    CGFloat percentage = _hero.hp* 100 / _hero.maxHp ;
    // LOG_VAR(percentage, @"%f");
    percentage = percentage < 0? 0 : percentage;
    percentage = percentage > 100 ? 100 : percentage;
    if (abs(_lifeIndicator.percentage - percentage) >= 1) {
        _lifeIndicator.percentage =percentage;
    }
}

- (void)update:(CCTime)delta
{
    [self updateBackground];
    [self updateLifeIndicator];
    
    if ([_hero dead]) {
        [self onGameOver];
        return;
    }
}

@end
