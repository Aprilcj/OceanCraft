//
//  Gameplay.h
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Gameplay : CCNode<CCPhysicsCollisionDelegate>
+ (void) loadLevel:(NSInteger) level;
@end
