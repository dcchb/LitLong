//
//  ViewController.h
//  Pal_app_vb6
//
//  Created by David Harris-Birtill on 22/12/2014.
//  The MIT License (MIT)
//
//Copyright (c) 2015 LitLong Edinburgh
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
////

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

