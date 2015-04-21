//
//  NSObject+Config.h
//  Pangu
//
//  Created by April on 15-4-10.
//  Copyright (c) 2015年 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Config)
- (id) objectFrom:(NSArray*)path;
- (NSDictionary*) dictFrom:(NSArray*)path;
- (NSArray*) arrayFrom:(NSArray*)path;
- (NSString*) stringFrom:(NSArray*)pth;
- (NSInteger) intFrom:(NSArray*)path;
- (CGFloat) doubleFrom:(NSArray*)path;

- (void)setProperties:(NSDictionary*)properties;
@end