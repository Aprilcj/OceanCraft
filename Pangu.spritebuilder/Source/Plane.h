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
@property NSString *planeFile;
@property (nonatomic, assign) CGFloat hp;
@property NSString *bulletFile;
- (void)onHit: (Bullet*)bullet;
- (void)onHitPlane: (Plane*)plane;
+ (Plane*) generate:(NSString*)planeFile;
-(void)setSpeed:(CGPoint)speed;
@end
