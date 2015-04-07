//
//  ScriptLoader.m
//  pangu
//
//  Created by April on 3/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ScriptLoader.h"

@implementation ScriptLoader{
    int _currentEnemy;
}

static NSInteger level;
static NSDictionary* script;

+ (NSDictionary*) loadLevel:(NSInteger) level{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%ld", (long)level] ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError* error;
    script = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return script;
}

+ (NSInteger)level{
    return level;
}

+ (NSDictionary*) script{
    return script;
}


- (NSDictionary*)nextEnemy{
    NSDictionary* script = [ScriptLoader script];
    NSArray* enemies = (NSArray*)[script objectForKey:@"enemies"];
    NSArray* names = [(NSDictionary*)[enemies indexOfObject:_currentEnemy] objectForKey:@"names"];
    return ;
}

@end
