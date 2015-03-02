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
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _bgs = @[_bg1, _bg2];
    _bullets = [NSMutableArray array];
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{

}

- (void)updateBackground:(CCTime)delta
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
    [self updateBackground:delta];
    [_hero fire:delta];
}

@end
