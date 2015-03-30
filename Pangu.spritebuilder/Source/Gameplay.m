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

static const float scrollSpeed = -50.f;

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
    
    _hero = [Plane generate:@"hero"];
    [_physicsNode addChild:_hero];
    [self addLifeIndicator];
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
    LOG_VAR(percentage, @"%f");
    percentage = percentage < 0? 0 : percentage;
    percentage = percentage > 100 ? 100 : percentage;
    if (_lifeIndicator.percentage != percentage) {
        _lifeIndicator.percentage =percentage;
    }
}

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

- (void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero_bullet:(CCNode *)nodeA enemy_bullet:(CCNode *)nodeB
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        [nodeA removeFromParent];
        [nodeB removeFromParent];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA enemy_bullet:(CCNode *)nodeB
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        Plane* plane = (Plane*)nodeA;
        Bullet* bullet = (Bullet*)nodeB;
        [plane onHitBullet:bullet];
        plane.physicsBody.velocity = ccp(0, 0);
        [nodeB removeFromParent];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy:(CCNode *)nodeA hero_bullet:(CCNode *)nodeB
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        Plane* plane = (Plane*)nodeA;
        Bullet* bullet = (Bullet*)nodeB;
        [plane onHitBullet:bullet];
        [bullet removeFromParent];
        if (plane.hp < 0) {
            _scoreValue += 1;
            _score.string = [NSString stringWithFormat:@"%d", _scoreValue];
        }
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA enemy:(CCNode *)nodeB
{
    LOG_FUN;
    [[_physicsNode space] addPostStepBlock:^{
        Plane* hero = (Plane*)nodeA;
        Plane* enemy = (Plane*)nodeB;
        [hero onHitPlane:enemy];
        hero.physicsBody.velocity = ccp(0, 0);
        [enemy onHitPlane:hero];
    } key:nodeA];
}

- (void)updateBackground
{
    CGSize _bgRect = [CCDirector sharedDirector].viewSize;
    for (CCNode* bg in _bgs) {
        if (bg.position.y <= -_bgRect.height) {
            LOG(@"_bgRect=(%f, %f)", _bgRect.width, _bgRect.height);
            bg.position = ccp(bg.position.x, bg.position.y+2*_bgRect.height);
        }
    }
}

- (void)addEnemy:(CCTime)delta{
    if ([_randomScheduler scheduled:delta]) {
        int random = arc4random()%100;
        
        if (random < 50) {
            Plane* plane = [Plane generate:@"small_plane"];
            [_hero.parent addChild:plane];
        }
        
        if (random < 10) {
            Plane* plane = [Plane generate:@"big_plane"];
            [_hero.parent addChild:plane];
        }
        
    }
}

-(void)onGameOver{
    _retryButton.visible = YES;
}

- (void)update:(CCTime)delta
{
    [self updateBackground];
    [self updateLifeIndicator];
    
    if ([_hero dead]) {
        [self onGameOver];
        return;
    }
    [self addEnemy:delta];
}

@end
