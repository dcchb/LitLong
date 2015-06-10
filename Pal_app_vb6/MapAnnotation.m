//
//  MapAnnotation.m
//  LitLong Edinburgh
//
//  Created by David Harris-Birtill on 13/03/2015.
//  Copyright (c) 2015 David Harris-Birtill. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize title,subtitle,coords_filename,coordinate;


- (id)initWithTitle:(NSString *)ttl subTitle:(NSString *)subttl coords_filename:(NSString *)c_filename andCoordinate:(CLLocationCoordinate2D)c2d {
    title = ttl;
    subtitle = subttl;
    coords_filename = c_filename;
    coordinate = c2d;
    
    return self;
}

@end