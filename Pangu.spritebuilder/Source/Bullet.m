//
//  Bullet.m
//  pangu
//
//  Created by April on 3/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet{
    
}

- (void)didLoadFromCCB{
    self.damage = 50;
    self.physicsBody.collisionType=@"bullet";
}

@end
