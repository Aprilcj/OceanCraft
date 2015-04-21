//
//  Penguin.h
//  PeevedPenguins
//
//  Created by April on 1/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"


@interface OCObject : CCSprite
@property (nonatomic, copy)NSString* file;
@property (nonatomic, retain) OCObject* bullet;
@property (nonatomic, assign) NSInteger maxHp;
@property (nonatomic, assign) NSInteger hp;
@property (nonatomic, assign) CCTime fireInterval;
@property (nonatomic, assign) CGPoint positionInPercent;
@property (nonatomic, retain) NSDictionary* config;
@property (nonatomic, copy) NSString* category;
@property (nonatomic, copy) NSString* sailTo;
@property (nonatomic, assign) CGPoint direction;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, copy) NSString* explosionEffect;
- (void)onHitPlane: (OCObject*)plane;
+ (OCObject*) generate:(NSString*)planeFile;
- (void)loadDefault:(NSString*)file;
-(BOOL)dead;
- (void)explode;
@end

static NSString* TYPE_HERO = @"hero";
static NSString* TYPE_HERO_BULLET = @"hero_bullet";
static NSString* TYPE_ENEMY = @"enemy";
static NSString* TYPE_ENEMY_BULLET = @"enemy_bullet";
static NSString* TYPE_EQUIPMENT = @"equipment";
static NSString* TYPE_ADORNMENT = @"adornment";


