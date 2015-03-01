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

static const float MIN_SPEED = 5.f;
static const float BASE_VELOCITY = 1000.f;
static const float STEP = .1f;
static const float scrollSpeed = 100.f;

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    CCNode *_levelNode;
    Plane *_hero;
    CCNode *_bg1;
    CCNode *_bg2;
    NSArray *_bgs;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _bgs = @[_bg1, _bg2];
    
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    
}

-(void) touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void)releaseCatapult:(CCTouch *)touch withEvent:(UIEvent *)event {
    
    
}

-(void) touchEnded:(CCTouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(UIEvent *)event
{
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchFrom = [touch previousLocationInView:[touch view]];
    CGPoint touchTo = [touch locationInView:[touch view]];
    CGPoint offset = ccpSub(touchTo, touchFrom);
    offset.y = - offset.y;
    
    CGPoint targetFrom = [_hero position];
    CGPoint targetTo = ccpAdd(targetFrom, ccp(offset.x, offset.y));
    [_hero setPosition:targetTo];
    
}

- (void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)sealRemoved:(CCNode *)seal {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = seal.position;
    [seal.parent addChild:explosion];
    [seal removeFromParent];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the seal
    if (energy > 5000.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
}

- (void)rollBackground:(CCTime)delta
{
    float height = _bg1.contentSize.height;
    float doubleHeight = 2*height;
    float offset = scrollSpeed*delta;
    for (CCNode* bg in _bgs) {
        CGPoint newPosition = bg.position;
        newPosition.y -= offset;
        if (newPosition.y <= -height) {
            newPosition.y += doubleHeight;
        }
        bg.position = newPosition;
    }
}

- (void)update:(CCTime)delta
{
    [self rollBackground:delta];
    
}

@end
