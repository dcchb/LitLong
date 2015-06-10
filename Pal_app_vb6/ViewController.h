//
//  ViewController.h
//  Pal_app_vb6
//
//  Created by David Harris-Birtill on 22/12/2014.
//  Copyright (c) 2014 David Harris-Birtill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak,nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UITextView *snippet_text;
@property (weak, nonatomic) IBOutlet UITextView *title_text;
@property (weak, nonatomic) IBOutlet UITextView *author_text;
@property (weak, nonatomic) IBOutlet UITextView *year_text;
@property (weak, nonatomic) IBOutlet UITextView *url_text;
@property (weak, nonatomic) IBOutlet UINavigationItem *text_view_nav_menu;
@property (weak, nonatomic) IBOutlet UIButton *next_snippt_button;

-(MKPointAnnotation*)closestAnnotation;
-(NSArray *)get_nearest_lat_long:get_nearest_lat_long lat_array_in:(NSArray*)lat_array_in lon_array_in:(NSArray*)lon_array_in lat_val:(double) lat_val lon_val:(double)lon_val;

@end

