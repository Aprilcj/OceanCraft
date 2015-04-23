//
//  Gameplay.h
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "OCObject.h"

@interface Gameplay : CCNode<CCPhysicsCollisionDelegate>
+ (Gameplay*)currentGame;

-(void)onHitDown: (OCObject*)plane;
-(void)completeMission;
-(void)changeBulletTo:(NSDictionary*)newBullet;
-(void)addLifeBy:(NSInteger)value;
-(void)changeFireIntervalTo:(CGFloat)value;
-(void)changeDamageTo:(NSInteger)value;
-(void)forkBullet:(NSInteger)value;
-(void)lifeSteal:(CGFloat)value;
-(void)damageRate:(CGFloat)value;
@end

