//
//  NSObject+Config.m
//  Pangu
//
//  Created by April on 15-4-10.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import "NSObject+Config.h"

@implementation NSObject (Config)

- (id) objectFrom: (NSArray*)path{
    if (path == nil || [path count] == 0) {
        return self;
    }
    id subPath = [path objectAtIndex:0];
    NSMutableArray* restPath = [NSMutableArray arrayWithArray:path];
    [restPath removeObjectAtIndex:0];
    
    id o = nil;
    if ([self isKindOfClass:[NSDictionary class]]){
        o = [((NSDictionary*)self) objectForKey:subPath];
        
    }else if ([self isKindOfClass:[NSArray class]]){
        o = [((NSArray*)self) objectAtIndex:[subPath integerValue]];
    }
    return [o objectFrom:restPath];
}

- (NSDictionary*) dictFrom:(NSArray*)path{
    return (NSDictionary*)[self objectFrom:path];
}

- (NSArray*) arrayFrom:(NSArray*)path{
    return (NSArray*)[self objectFrom:path];
}

- (NSString*) stringFrom:(NSArray*)path{
    return (NSString*)[self objectFrom:path];
}

- (NSInteger) intFrom:(NSArray*)path{
    return [[self objectFrom:path] integerValue];
}

- (CGFloat) doubleFrom:(NSArray*)path{
    return [[self objectFrom:path] doubleValue];
}

- (void)setProperties:(NSDictionary*)properties{
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        id target = [self valueForKey:key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            id subObject = [self valueForKey:key];
            [subObject setProperties:obj];
        }else{
            [self setValue:obj forKey:key];
        }
    }];
}

@end
