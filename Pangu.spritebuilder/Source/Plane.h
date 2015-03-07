//
//  Penguin.h
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Plane : CCSprite
@property NSString *planeFile;
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, assign) CCTime fireInterval;
@property NSString *bulletFile;
@property (nonatomic, assign) CGVector bulletSpeed;
@property (nonatomic, assign) CGVector planeSpeed;
-(void)fire:(CCTime)delta;
+ (Plane*) generate:(NSString*)planeFile;
@end
