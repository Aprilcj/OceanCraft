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

static const float scrollSpeed = 50.f;

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
    NSMutableArray *_planes;
    CGSize _bgRect;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _bgs = @[_bg1, _bg2];
    _bgRect = [CCDirector  sharedDirector].viewSize;
    _bullets = [NSMutableArray array];
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
//    _physicsNode.debugDraw = YES;
    _randomScheduler = [IntervalScheduler getInstance:1.f];
    _planes = [NSMutableArray array];
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
    [[_physicsNode space] addPostStepBlock:^{
        [self planeRemove:nodeA];
        [nodeB removeFromParent];
    } key:nodeA];
}

- (void)planeRemove:(CCNode *)plane {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    explosion.position = plane.position;
    [plane.parent addChild:explosion];
    explosion.autoRemoveOnFinish = YES;
    
    [plane removeFromParent];
    [_planes removeObject:plane];
}

- (void)updateBackground:(CCTime)delta
{
    float doubleHeight = 2*_bgRect.height;
    float offset = scrollSpeed*delta;
    for (CCNode* bg in _bgs) {
        CGPoint newPosition = bg.position;
        newPosition.y -= offset;
        if (newPosition.y <= -_bgRect.height) {
            newPosition.y += doubleHeight;
        }
        bg.position = newPosition;
    }
}

- (void)addEnemy:(CCTime)delta{
    if ([_randomScheduler scheduled:delta]) {
        int random = arc4random()%100;
        if (random < 50) {
            Plane* plane = [Plane generate:@"small_plane"];
            plane.position = ccp((arc4random()%((int)(_bgRect.width-plane.contentSize.width)))+plane.contentSize.width/2, _bgRect.height);
            [_planes addObject:plane];
            [_hero.parent addChild:plane];
        }
    }
}

- (void) moveEnemy{
    NSMutableArray *itemsToBeRemoved = [NSMutableArray array];
    for (Plane* plane in _planes) {
        plane.position=ccp(plane.position.x + plane.planeSpeed.dx,plane.position.y+plane.planeSpeed.dy);
        if (plane.position.y < 0) {
            [itemsToBeRemoved addObject:plane];
        }
    }
    for (Plane* plane in itemsToBeRemoved) {
        [_planes removeObject:plane];
        [_hero.parent removeChild:plane];
    }
}
- (void)update:(CCTime)delta
{
    [self updateBackground:delta];
    [_hero fire:delta];
    [self addEnemy:delta];
    [self moveEnemy];
}

@end
