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
}

// is called when CCB file has completed loading
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
    
    [_hero setSpeed:ccp(0, 0)];
    _hero.physicsBody.collisionType = @"hero";
    _hero.physicsBody.collisionMask = @[@"enemy_bullet",@"enemy"];
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    LOG(@"_hero.physicType = %@", _hero.physicsBody.collisionType);
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair hero:(CCNode *)nodeA enemy_bullet:(CCNode *)nodeB
{
    Plane* plane = (Plane*)nodeA;
    Bullet* bullet = (Bullet*)nodeB;
    
    [[_physicsNode space] addPostStepBlock:^{
        [plane onHitBullet:bullet];
        [nodeB removeFromParent];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy:(CCNode *)nodeA hero_bullet:(CCNode *)nodeB
{
    Plane* plane = (Plane*)nodeA;
    Bullet* bullet = (Bullet*)nodeB;
    
    [[_physicsNode space] addPostStepBlock:^{
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
    Plane* planeA = (Plane*)nodeA;
    Plane* planeB = (Plane*)nodeB;
    [[_physicsNode space] addPostStepBlock:^{
        [planeA onHitPlane:planeB];
        [planeB onHitPlane:planeA];
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

- (Plane*) newEnemy:(NSString*)planeFile{
    CGSize world = [CCDirector  sharedDirector].viewSize;
    Plane* plane = (Plane*)[CCBReader load:planeFile];
    plane.position = ccp((arc4random()%((int)(world.width-plane.contentSize.width)))+plane.contentSize.width/2, world.height);
    plane.bulletFile = nil;
    plane.physicsBody.collisionType = @"enemy";
    plane.physicsBody.collisionMask = @[@"hero_bullet",@"hero"];
    return plane;
}

- (void)addEnemy:(CCTime)delta{
    if ([_randomScheduler scheduled:delta]) {
        int random = arc4random()%100;
        
        if (random < 50) {
            Plane* plane = [self newEnemy:@"small_plane"];
            [_hero.parent addChild:plane];
        }
        
        if (random < 10) {
            Plane* plane = [self newEnemy:@"big_plane"];
            plane.hp = 500;
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
    
    if (_hero.hp < 0) {
        LOG(@"game over", @"");
        [self onGameOver];
        return;
    }
    [self addEnemy:delta];
}

@end
