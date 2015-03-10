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
    Plane *_hero;
    CCNode *_bg1;
    CCNode *_bg2;
    NSArray *_bgs;
    NSArray *_bullets;
    IntervalScheduler *_randomScheduler;
    //NSMutableArray *_planes;
    CGSize _bgRect;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _bgs = @[_bg1, _bg2];
    for (CCNode* bg in _bgs) {
        [bg.physicsBody setVelocity:ccp(0, scrollSpeed)];
        bg.physicsBody.collisionMask = @[];
    }
    
    _bgRect = [CCDirector  sharedDirector].viewSize;
    _bullets = [NSMutableArray array];
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    //_physicsNode.debugDraw = YES;
    _randomScheduler = [IntervalScheduler getInstance:1.f];
    [_hero setSpeed:ccp(0, 0)];
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair plane:(CCNode *)nodeA bullet:(CCNode *)nodeB
{
    Plane* plane = (Plane*)nodeA;
    Bullet* bullet = (Bullet*)nodeB;
    [[_physicsNode space] addPostStepBlock:^{
        [plane onHit:bullet];
        [nodeB removeFromParent];
    } key:nodeA];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair plane:(CCNode *)nodeA plane:(CCNode *)nodeB
{
    Plane* planeA = (Plane*)nodeA;
    Plane* planeB = (Plane*)nodeB;
    [[_physicsNode space] addPostStepBlock:^{
        [planeA onHitPlane:planeA];
        [planeB onHitPlane:planeB];
    } key:nodeA];
}

- (void)updateBackground
{
    for (CCNode* bg in _bgs) {
        if (bg.position.y <= -_bgRect.height) {
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


- (void)update:(CCTime)delta
{
    [self updateBackground];
    [self addEnemy:delta];
}

@end
