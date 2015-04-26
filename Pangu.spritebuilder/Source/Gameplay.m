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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

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
    
    // dialog
    CCNode* _dialog;
    
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
    NSInteger repeat = [_currentScript.script intFrom:@[@"repeat"]];
    NSArray* actors = [_currentScript.script arrayFrom:@[@"actors"]];
    switch (repeat) {
        case -1:
            //infinity
            break;
            
        default:
            if (_currentActor > repeat - 1) {
                 LOG(@"script over", nil);
                return;
            }
            break;
    }
    
    LOG(@"load actor: %ld", _currentActor);
    NSInteger index = _currentActor++;
    if (index == repeat - 1) {
        //terminal
        [self addActor:[actors count]-1];
        return;
    }
    
    if ([_currentScript.script intFrom:@[@"random"]] > 0) {
        index = arc4random()%([actors count] -1);
    }
    [self addActor:index];
    
}

- (void)addActor:(NSInteger)index{
    NSNumber* indexNumber = [NSNumber numberWithInteger:index];
    NSDictionary* actor = [_currentScript.script dictFrom:@[@"actors", indexNumber]] ;
    NSArray* roles = [actor arrayFrom:@[@"roles"]];
    CGFloat delay = [actor doubleFrom:@[@"delay"]];
    if (delay < MIN_UNIT) {
        delay = [_currentScript.script doubleFrom:@[@"delay"]];
    }
    
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
    } delay:delay];
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
    
    CGSize world = [CCDirector  sharedDirector].viewSize;
    float xMin = _hero.contentSize.width/2;
    float yMin = _hero.contentSize.height/2;
    float xMax = world.width-xMin;
    float yMax = world.height - yMin;
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

-(void)setBulletProperties:(NSDictionary*)newBullet{
    [_hero.bullet setProperties:newBullet];
}

-(void)setHeroProperties:(NSDictionary*)properties{
    [_hero setProperties:properties];
}

-(void)addLifeBy:(NSInteger)value{
    _hero.hp = MIN(_hero.hp + value, _hero.maxHp);
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
    }delay:2];
}

-(void)onGameOver{
    _retryButton.visible = YES;
}

- (void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"] withTransition:[CCTransition transitionFadeWithDuration:1]];
}

- (void)back{
    self.paused = YES;
    _dialog.visible = YES;
}

- (void)quit{
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition:[CCTransition transitionFadeWithDuration:1]];
}

- (void)share{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    
    // this should link to FB page for your app or AppStore link if published
    content.contentURL = [NSURL URLWithString:@"https://www.facebook.com/makeschool"];
    // URL of image to be displayed alongside post
    content.imageURL = [NSURL URLWithString:@"https://git.makeschool.com/MakeSchool-Tutorials/News/f744d331484d043a373ee2a33d63626c352255d4//663032db-cf16-441b-9103-c518947c70e1/cover_photo.jpeg"];
    // title of post
    content.contentTitle = [NSString stringWithFormat:@"test!"];
    content.contentDescription = @"Details of test";
    
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                 withContent:content
                                    delegate:nil];
}

- (void)resume{
    _dialog.visible = NO;
    self.paused = NO;
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
