//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Plane.h"
#import "IntervalScheduler.h"
#import "Bullet.h"
#import "cocos2d.h"
#import "ScriptLoader.h"
#import "NSObject+Config.h"

static const float scrollSpeed = -50.f;

#pragma mark init

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    CCNode *_levelNode;
    CCLabelTTF *_score;
    int _scoreValue;
    Plane *_hero;
    CCNode *_bg1;
    CCNode *_bg2;
    NSArray *_bgs;
    IntervalScheduler *_randomScheduler;
    CCButton *_retryButton;
    CCSprite *_life;
    CCProgressNode *_lifeIndicator;
    NSUInteger _currentScene;
}

- (void)didLoadFromCCB {
    _bgs = @[_bg1, _bg2];
    for (CCNode* bg in _bgs) {
        [bg.physicsBody setVelocity:ccp(0, scrollSpeed)];
        bg.physicsBody.collisionMask = @[];
    }
    _randomScheduler = [IntervalScheduler getInstance:1.f];
    
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = YES;
    
    //init hero
    _hero = [Plane generate:@"hero"];
    [_physicsNode addChild:_hero];
    
    
    [self addLifeIndicator];
    
    _currentScene = 0;
    [self addRoles];
}

- (void) addRoles{
    ScriptLoader* script = [ScriptLoader currentLevel];
    NSArray* scenes = [script.script arrayFrom:@[@"scenes"]];
    if (_currentScene > [scenes count] - 1) {
        LOG(@"script over", nil);
        return;
    }
    LOG(@"load scene: %ld", _currentScene);
    NSDictionary* scene =  [scenes dictFrom:@[[NSNumber numberWithUnsignedInteger:_currentScene++]]];
    NSArray* roles = [scene arrayFrom:@[@"roles"]];
    
    [self scheduleBlock:^(CCTimer* timer){
        for (NSDictionary* role in roles) {
            NSString* name = [role stringFrom:@[@"name"]];
            NSString* deadCallback = [role stringFrom:@[@"deadCallback"]];
            if (deadCallback) {
                LOG_FUN;
            }
            NSDictionary* properties = [role dictFrom:@[@"properties"]];
            //if ([name hasSuffix:@"plane"]) {
            Plane* plane = [Plane generate:name];
            plane.deadCallback = deadCallback;
            if (properties){
                [plane setProperties:properties];
            }
            [_hero.parent addChild:plane];
            // }
        }
        [self addRoles];
    } delay:[scene doubleFrom:@[@"delay"]]];
    
}

- (void)addLifeIndicator{
    _lifeIndicator = [CCProgressNode progressWithSprite:_life];
    _lifeIndicator.type = CCProgressNodeTypeBar;
    _lifeIndicator.midpoint = ccp(0.0f, 0.0f);
    _lifeIndicator.barChangeRate = ccp(1.0f, 0.0f);
    _lifeIndicator.percentage = 0.0f;
    
    _lifeIndicator.positionType = CCPositionTypeNormalized;
    _lifeIndicator.anchorPoint = ccp(0, 0);
    _lifeIndicator.position = ccp(0, 0);
    [_contentNode addChild:_lifeIndicator];
}

- (void)updateLifeIndicator{
    CGFloat percentage = _hero.hp / _hero.maxHp * 100;
    // LOG_VAR(percentage, @"%f");
    percentage = percentage < 0? 0 : percentage;
    percentage = percentage > 100 ? 100 : percentage;
    if (_lifeIndicator.percentage != percentage) {
        _lifeIndicator.percentage =percentage;
    }
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero_bullet:(Bullet *)hero_bullet enemy_bullet:(Bullet *)enemy_bullet
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [hero_bullet onHit];
        [enemy_bullet onHit];
    } key:hero_bullet];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(Plane *)hero enemy_bullet:(Bullet *)enemy_bullet
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [hero onHitBullet:enemy_bullet];
        hero.physicsBody.velocity = ccp(0, 0);
        [enemy_bullet onHit];
    } key:hero];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy:(Plane *)enemy hero_bullet:(Bullet *)hero_bullet
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [enemy onHitBullet:hero_bullet];
        [hero_bullet onHit];
        
        [self onHitEnemy:enemy];
    } key:enemy];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(Plane *)hero enemy:(Plane *)enemy
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [hero onHitPlane:enemy];
        [enemy onHitPlane:hero];
        
        hero.physicsBody.velocity = ccp(0, 0);
        [self onHitEnemy:enemy];
    } key:hero];
}

#pragma mark on event

-(void)onHitEnemy: (Plane*)enemy{
    if ([enemy dead]) {
        _scoreValue += enemy.maxHp;
        _score.string = [NSString stringWithFormat:@"%d", _scoreValue];
        if (enemy.deadCallback) {
            LOG_VAR(enemy.deadCallback, @"%@");
            SEL callback = NSSelectorFromString(enemy.deadCallback);
            if ([self respondsToSelector:callback]){
                [self performSelector:callback];
            }else{
                LOG(@"can't find callback: %@", enemy.deadCallback);
            }
        }
    }
}

-(void)onMissionComplete{
    LOG_FUN;
    [self scheduleBlock:^(CCTimer* cctimer){
        CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
        [[CCDirector sharedDirector] replaceScene:mainScene];
    }delay:3];
}

-(void)onGameOver{
    _retryButton.visible = YES;
}

- (void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

#pragma mark update

- (void)updateBackground
{
    CGSize _bgRect = [CCDirector sharedDirector].viewSize;
    for (CCNode* bg in _bgs) {
        if (bg.position.y <= -_bgRect.height) {
            //LOG(@"_bgRect=(%f, %f)", _bgRect.width, _bgRect.height);
            bg.position = ccp(bg.position.x, bg.position.y+2*_bgRect.height);
        }
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
