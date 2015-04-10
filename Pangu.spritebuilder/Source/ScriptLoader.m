//
//  ScriptLoader.m
//  pangu
//
//  Created by April on 3/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ScriptLoader.h"

static const NSString* SCENES = @"scenes";
static const NSString* ROLES = @"roles";
static const NSString* ROLE = @"role";
static const NSString* PROPERTIES = @"properties";

@implementation ScriptLoader{
}

static ScriptLoader* s_currentLevel;


#pragma mark init
- (id)initWithLevel:(NSUInteger)level{
    
    if (self = [super init]) {
        self.level = level;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%ld", (long)level] ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError* error;
        self.script = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    return self;
}

+ (void) loadLevel:(NSInteger) level{
    s_currentLevel = [[ScriptLoader alloc]initWithLevel:level];
}

+ (ScriptLoader*)currentLevel{
    return s_currentLevel;
}
@end
