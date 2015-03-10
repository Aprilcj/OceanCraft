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
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, assign) CCTime fireInterval;
@property NSString *bulletFile;
@property (nonatomic, assign) CGPoint bulletSpeed;
@property (nonatomic, assign) CGVector planeSpeed;
@property (nonatomic, assign) CGFloat hp;
-(void)fire:(CCTime)delta;
- (void)onHit: (Bullet*)bullet;
+ (Plane*) generate:(NSString*)planeFile;
@end
