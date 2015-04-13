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

static NSSet* CGPointProperties;

+ (BOOL) isCGPoint:(NSString*)propertyName{
    if (!CGPointProperties) {
        CGPointProperties = [NSSet setWithObjects:@"velocity",@"position",@"positionInPercent",nil];
    }
    return [CGPointProperties containsObject:propertyName];
}

+ (id)nsvalueWithKey:(id)key value:(id)value{
    if ([NSObject isCGPoint:key]) {
        return [NSValue valueWithCGPoint:ccp([[value objectForKey:@"x"] doubleValue], [[value objectForKey:@"y"] doubleValue])];
    }
    return value;
}

- (void)setProperties:(NSDictionary*)properties{
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
        id targetProperty = [self valueForKey:key];
        
        // e.g. self.position = ccp(0,0);
        if ([targetProperty isKindOfClass:[NSValue class]]){
            id nsvalue = [NSObject nsvalueWithKey:key value:value];
            [self setValue:nsvalue forKey:key];
            return;
        }
        
        // recursively apply sub properties
        if ([value isKindOfClass:[NSDictionary class]]) {
            [targetProperty setProperties:value];
            return;
        }
        
        [self setValue:value forKey:key];
    }];
}

@end
