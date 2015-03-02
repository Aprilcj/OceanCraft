//
//  Penguin.h
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Plane : CCSprite
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, assign) CCTime fireInterval;
@property (nonatomic, assign) CGFloat bulletSpeed;
@property NSString *bulletName;
-(void)fire:(CCTime)delta;
@end
