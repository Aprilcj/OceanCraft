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
@property (nonatomic, copy)NSString* file;
@property (nonatomic, retain) Bullet* bullet;
@property (nonatomic, assign) NSInteger maxHp;
@property (nonatomic, assign) NSInteger hp;
@property (nonatomic, assign) CCTime fireInterval;
@property (nonatomic, assign) CGPoint positionInPercent;
@property (nonatomic, retain) NSDictionary* config;
@property (nonatomic, copy) NSString* category;

- (void)onHitBullet: (Bullet*)bullet;
- (void)onHitPlane: (Plane*)plane;
+ (Plane*) generate:(NSString*)planeFile;
- (void)loadDefault:(NSString*)file;
-(BOOL)dead;
@end

static NSString* TYPE_HERO = @"hero";
static NSString* TYPE_HERO_BULLET = @"hero_bullet";
static NSString* TYPE_ENEMY = @"enemy";
static NSString* TYPE_ENEMY_BULLET = @"enemy_bullet";
static NSString* TYPE_EQUIPMENT = @"equipment";
static NSString* TYPE_ADORNMENT = @"adornment";


