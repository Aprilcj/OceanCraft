//
//  ScriptLoader.h
//  pangu
//
//  Created by April on 3/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptLoader : NSObject

+(ScriptLoader*) loaderOfLevel:(NSInteger)level;
//+(ScriptLoader*) loaderOfFile:(NSString*)file;
@property (nonatomic, retain) NSDictionary* script;

@end
