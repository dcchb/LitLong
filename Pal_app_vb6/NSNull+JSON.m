//
//  NSNull+JSON.m
//  LitLong Edinburgh
//
//  Created by David Harris-Birtill on 11/03/2015.
//  Copyright (c) 2015 David Harris-Birtill. All rights reserved.
//
//  On 11th March downloaded code from: http://stackoverflow.com/questions/16607960/nsnull-length-unrecognized-selector-sent-to-json-objects

#import <Foundation/Foundation.h>


@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (float)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

@end