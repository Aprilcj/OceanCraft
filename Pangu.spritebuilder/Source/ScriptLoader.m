//
//  ScriptLoader.m
//  pangu
//
//  Created by April on 3/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ScriptLoader.h"

@implementation ScriptLoader{
}

#pragma mark init
+(ScriptLoader*) loaderOfLevel:(NSInteger)level{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%ld", level] ofType:@"json"];
    return [[ScriptLoader alloc] initWithFile:filePath];
}

+(ScriptLoader*)loaderOfFile:(NSString *)file{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    return [[ScriptLoader alloc] initWithFile:filePath];
}

- (id)initWithFile:(NSString*)file{
    
    if (self = [super init]) {
        NSData *data = [NSData dataWithContentsOfFile:file];
        NSError* error;
        self.script = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    return self;
}

@end
