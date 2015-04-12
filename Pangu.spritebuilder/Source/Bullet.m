//
//  Bullet.m
//  pangu
//
//  Created by April on 3/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet{
    NSArray* _velocity;
}

@synthesize velocity = _velocity;

+ (Bullet*)duplicate:(Bullet *)bullet{
    if (!bullet.file || bullet.file.length == 0) {
        return nil;
    }
    Bullet* newBullet = (Bullet*)[CCBReader load:bullet.file];
    newBullet.file = bullet.file;
    newBullet.damage = bullet.damage;
    newBullet.range = bullet.range;
    newBullet.velocity = bullet.velocity;
    //newBullet.physicsBody.velocity = bullet.physicsBody.velocity;
    newBullet.physicsBody.collisionType = bullet.physicsBody.collisionType;
    newBullet.physicsBody.collisionMask = bullet.physicsBody.collisionMask;
    return newBullet;
}

- (void)setVelocity:(NSArray *)velocity{
    _velocity = velocity;
    self.physicsBody.velocity = ccp([velocity[0] doubleValue], [velocity[1] doubleValue]);
}

-(void)onHit{
    [self removeFromParent];
}

+ (Bullet*)generate:(NSString *)bulletFile{
    Bullet* bullet = (Bullet*)[CCBReader load:bulletFile];
    bullet.file = bulletFile;
    bullet.damage = 100;
    bullet.range = [CCDirector sharedDirector].viewSize.height;
    bullet.velocity = @[@0, @-150];
    return bullet;
}

-(void)update:(CCTime)delta{
    if (self.position.y > self.range) {
        [self removeFromParent];
        return;
    }
}
@end
