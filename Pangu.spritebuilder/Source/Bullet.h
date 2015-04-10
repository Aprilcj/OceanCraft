//
//  Bullet.h
//  pangu
//
//  Created by April on 3/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@interface Bullet : CCSprite
@property (nonatomic, assign) CGFloat damage;
@property (nonatomic, assign) CGFloat range;
@property (nonatomic, retain) NSArray* velocity;

@property NSString* file;
+ (Bullet*) generate:(NSString*)bulletFile;
+ (Bullet*) duplicate:(Bullet*)bullet;
@end
