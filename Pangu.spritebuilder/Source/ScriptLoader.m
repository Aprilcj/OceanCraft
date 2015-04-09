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

#pragma mark util

+ (id) objectFrom: (id)object withPath:(NSArray*)path{
    if (path == nil || [path count] == 0) {
        return object;
    }
    id subPath = [path objectAtIndex:0];
    NSMutableArray* restPath = [NSMutableArray arrayWithArray:path];
    [restPath removeObjectAtIndex:0];
    
    id o = nil;
    if ([object isKindOfClass:[NSDictionary class]]){
        o = [((NSDictionary*)object) objectForKey:subPath];
        
    }else if ([object isKindOfClass:[NSArray class]]){
        o = [((NSArray*)object) objectAtIndex:[subPath integerValue]];
    }
    return [ScriptLoader objectFrom:o withPath:restPath];
}

+ (NSDictionary*) dictFrom: (id)object withPath:(NSArray*)path{
    return (NSDictionary*)[ScriptLoader objectFrom:object withPath:path];
}

+ (NSArray*) arrayFrom: (id)object withPath:(NSArray*)path{
    return (NSArray*)[ScriptLoader objectFrom:object withPath:path];
}

+ (NSString*) stringFrom: (id)object withPath:(NSArray*)path{
    return (NSString*)[ScriptLoader objectFrom:object withPath:path];
}

+ (NSInteger) intFrom: (id)object withPath:(NSArray*)path{
    return [[ScriptLoader objectFrom:object withPath:path] integerValue];
}

@end
