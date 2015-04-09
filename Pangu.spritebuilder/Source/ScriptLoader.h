//
//  ScriptLoader.h
//  pangu
//
//  Created by April on 3/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptLoader : NSObject
+ (void) loadLevel:(NSInteger) level;
+ (ScriptLoader*)currentLevel;

+ (id) objectFrom: (id)object withPath:(NSArray*)path;
+ (NSDictionary*) dictFrom: (id)object withPath:(NSArray*)path;
+ (NSArray*) arrayFrom: (id)object withPath:(NSArray*)path;
+ (NSString*) stringFrom: (id)object withPath:(NSArray*)pth;
+ (NSInteger) intFrom: (id)object withPath:(NSArray*)path;

@property (nonatomic, assign) NSInteger level;
@property (atomic, retain) NSDictionary* script;
@end
