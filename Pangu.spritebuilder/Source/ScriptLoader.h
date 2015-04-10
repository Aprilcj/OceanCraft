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

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, retain) NSDictionary* script;
@end
