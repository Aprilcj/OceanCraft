//
//  Bullet.h
//  pangu
//
//  Created by April on 3/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@interface Bullet : CCSprite
@property (nonatomic, copy)NSString* file;
@property (nonatomic, assign) CGFloat damage;
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, retain) NSArray* velocity;
+ (Bullet*) generate:(NSString*)bulletFile;
+ (Bullet*) duplicate:(Bullet*)bullet;
- (void)onHit;
@end
