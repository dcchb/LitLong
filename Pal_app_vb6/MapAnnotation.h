//
//  MapAnnotation.m
//  LitLong Edinburgh
//
//  Created by David Harris-Birtill on 13/03/2015.
//  Copyright (c) 2015 David Harris-Birtill. All rights reserved.
//
//Adapted from: http://stackoverflow.com/questions/15134382/how-to-extend-mkpointannotation-and-add-a-property-to-it
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : MKPointAnnotation
{
    NSString *title;
    NSString *subtitle;
    NSString *coords_filename;
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) NSString *coords_filename;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)ttl subTitle:(NSString *)subttl coords_filename:(NSString *)c_filename andCoordinate:(CLLocationCoordinate2D)c2d;

@end