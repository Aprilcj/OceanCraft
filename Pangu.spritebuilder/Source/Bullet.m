//
//  Bullet.m
//  pangu
//
//  Created by April on 3/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet{
    NSString* _owner;
}

+ (Bullet*)duplicate:(Bullet *)bullet{
    Bullet* newBullet = (Bullet*)[CCBReader load:bullet.file];
    newBullet.file = bullet.file;
    newBullet.damage = bullet.damage;
    newBullet.range = bullet.range;
    [newBullet setOwner:[bullet owner]];
    [newBullet.physicsBody setVelocity:bullet.physicsBody.velocity];
    newBullet.physicsBody.collisionType = bullet.physicsBody.collisionType;
    newBullet.physicsBody.collisionMask = bullet.physicsBody.collisionMask;
    return newBullet;
}

+ (Bullet*)generate:(NSString *)bulletFile{
    Bullet* bullet = (Bullet*)[CCBReader load:bulletFile];
    bullet.file = bulletFile;
    bullet.damage = 100;
    bullet.range = [CCDirector sharedDirector].viewSize.height;
    [bullet.physicsBody setVelocity:ccp(0, -150)];
    if ([bulletFile isEqual:@"bullet1"]){
        
    }
    return bullet;
}

- (void)setOwner:(NSString*)owner{
    _owner = owner;
    self.physicsBody.collisionType = [_owner stringByAppendingString:@"_bullet"];
    self.physicsBody.collisionMask = @[@"enemy"];
}

- (NSString*)owner{
    return _owner;
}

-(void)update:(CCTime)delta{
    if (self.position.y > self.range) {
        [self removeFromParent];
        return;
    }
}
@end
