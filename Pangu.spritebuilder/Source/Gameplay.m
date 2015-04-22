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
    
    //score
    CCLabelTTF *_score;
    int _scoreValue;
    
    //hero
    OCObject *_hero;

    //background
    CCNode *_bg1;
    CCNode *_bg2;
    NSArray *_bgs;
    
    CCNode* _adornment;
    NSInteger _currentAdornment;
    
    CCButton *_retryButton;
    
    //lifebar
    CCSprite *_lifebar_fill;
    CCProgressNode *_lifeIndicator;
    CCNode* _lifebar_bg;
    CCNode* _lifebar_container;
    
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
    _currentLevel = [MainScene unlockedLevel];
    
    //_physicsNode.debugDraw = YES;
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
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
    _currentActor = 0;
    [self addRoles];
    
    //adornment
    _currentAdornment = 0;
    //[self addAdornment];
}

- (void) addRoles{
    ScriptLoader* script = [ScriptLoader loaderOfLevel:_currentLevel];
    NSArray* actors = [script.script arrayFrom:@[@"actors"]];
    if (_currentActor > [actors count] - 1) {
        LOG(@"script over", nil);
        return;
    }
    LOG(@"load scene: %ld", _currentActor);
    NSDictionary* actor =  [actors dictFrom:@[[NSNumber numberWithUnsignedInteger:_currentActor++]]];
    NSArray* roles = [actor arrayFrom:@[@"roles"]];
    
    [self scheduleBlock:^(CCTimer* timer){
        for (NSDictionary* role in roles) {
            NSString* name = [role stringFrom:@[@"name"]];
            NSString* category = [role stringFrom:@[@"category"]];
            NSDictionary* properties = [role dictFrom:@[@"properties"]];
            
            OCObject* object = (OCObject*)[OCObject generate:name category:category];
            object.config = role;
            if (properties){
                [object setProperties:properties];
            }
            [_hero.parent addChild:object];
            
        }
        [self addRoles];
    } delay:[actor doubleFrom:@[@"delay"]]];
    
}

- (void) addAdornment{
    ScriptLoader* script = [ScriptLoader loaderOfFile:@"adornment"];
    NSArray* adornmentGroups = [script.script arrayFrom:@[@"adornments"]];
    if (_currentAdornment == [adornmentGroups count]) {
        _currentAdornment = 0;
    }
    LOG(@"load adornment: %ld", _currentAdornment);
    NSDictionary* adornmentGroup =  [adornmentGroups dictFrom:@[[NSNumber numberWithUnsignedInteger:_currentAdornment++]]];
    NSArray* objects = [adornmentGroup arrayFrom:@[@"objects"]];
    
    [self scheduleBlock:^(CCTimer* timer){
        for (NSDictionary* role in objects) {
            NSString* name = [role stringFrom:@[@"name"]];
            NSDictionary* properties = [role dictFrom:@[@"properties"]];
            
            CCNode* object =[CCBReader load:name];
            if (properties){
                [object setProperties:properties];
            }
            [_adornment addChild:object];
            
        }
        [self addAdornment];
    } delay:[adornmentGroup doubleFrom:@[@"delay"]]];
    
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

- (void)updateLifeIndicator{
    CGFloat percentage = _hero.hp* 100 / _hero.maxHp ;
    // LOG_VAR(percentage, @"%f");
    percentage = percentage < 0? 0 : percentage;
    percentage = percentage > 100 ? 100 : percentage;
    if (abs(_lifeIndicator.percentage - percentage) >= 1) {
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero_bullet:(OCObject *)hero_bullet enemy_bullet:(OCObject *)enemy_bullet
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [hero_bullet explode];
        [enemy_bullet explode];
    } key:hero_bullet];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(OCObject *)hero enemy_bullet:(OCObject *)enemy_bullet
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [hero onHit:enemy_bullet];
        hero.physicsBody.velocity = ccp(0, 0);
        [enemy_bullet explode];
    } key:hero];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy:(OCObject *)enemy hero_bullet:(OCObject *)hero_bullet
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [enemy onHit:hero_bullet];
        [hero_bullet explode];
    } key:enemy];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(OCObject *)hero enemy:(OCObject *)enemy
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [hero onHit:enemy];
        [enemy onHit:hero];
        
        hero.physicsBody.velocity = ccp(0, 0);
    } key:hero];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(OCObject *)hero equipment:(OCObject *)equipment
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [equipment onHit:hero];
        hero.physicsBody.velocity = ccp(0, 0);
    } key:hero];
}

#pragma mark on event

-(void)onHitDown: (OCObject*)plane{
    if ([plane isEqual:_hero]) {
        return;
    }
    _scoreValue += plane.maxHp;
    _score.string = [NSString stringWithFormat:@"%d", _scoreValue];
}

-(void)changeBullet:(NSDictionary*)newBullet{
    [_hero.bullet setProperties:newBullet];
}

-(void)onMissionComplete{
    LOG_FUN;
    [self scheduleBlock:^(CCTimer* cctimer){
        if ([_hero dead]) {
            return;
        }
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
