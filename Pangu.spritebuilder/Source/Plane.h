//
//  Penguin.h
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Bullet.h"



@interface Plane : CCSprite
@property (atomic, retain) Bullet* bullet;
@property (nonatomic, assign) float maxHp;
@property (nonatomic, assign) float hp;
- (void)onHitBullet: (Bullet*)bullet;
- (void)onHitPlane: (Plane*)plane;
+ (Plane*) generate:(NSString*)planeFile;
-(void)setFireInterval:(CCTime)fireInterval;
-(BOOL)dead;
@end
