//
//  ViewController.m
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
//  LitLong Edinburgh was created as part of the Palimpsest project
//
// To contact David email: birtill {at} hotmail.com

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "SWRevealViewController.h"
#import "math.h"
#import "MapAnnotation.h"

@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
    NSMutableArray *lat_array;
    NSMutableArray *long_array;
    int snippet_number;
    int max_num_snippets;
    MapAnnotation  *current_annotation;
    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.mapView.zoomEnabled = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    
    //load lat long data
    NSString *file_contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lat_long_edin_area_final_launch" ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *numscontentArray = [file_contents componentsSeparatedByString:@"\n"];
    long double lat_val;
    long double long_val;
    float lat_value;
    float long_value;
    NSInteger num_mentions;
    NSString *num_mentions_string;
    NSString *placename;
    NSString *lat_str;
    NSString *long_str;

    float edinspanX = 0.0025;//1 mile  = 0.00725
    float edinspanY = 0.0025;
    MKCoordinateRegion region;
    region.center.latitude = 55.9531;//Edinburgh
    region.center.longitude = -3.1889;//Edinburgh
    region.span.latitudeDelta = edinspanX;
    region.span.longitudeDelta = edinspanY;
    [self.mapView setRegion:region];
    
    if(lat_array == NULL){
     lat_array = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if(long_array == NULL){
      long_array = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if(snippet_number == NULL){
        snippet_number = 0;
    }
    if(max_num_snippets == NULL){
        max_num_snippets = 0;
    }
    
    //NSDate *start = [NSDate date];
    for (NSString *item in numscontentArray) {
       // NSLog(@"Here a ");

        NSArray *itemArray = [item componentsSeparatedByString:@","];
        lat_val = [[itemArray objectAtIndex:0] doubleValue];//doubleValue
        long_val = [[itemArray objectAtIndex:1] doubleValue];
        lat_value = [[itemArray objectAtIndex:0] doubleValue];//doubleValue
        long_value = [[itemArray objectAtIndex:1] doubleValue];
        lat_str = [itemArray objectAtIndex:0];
        long_str = [itemArray objectAtIndex:1];
        [lat_array addObject:[NSNumber numberWithDouble:lat_val]];
        [long_array addObject:[NSNumber numberWithDouble:long_val]];

        num_mentions = [[itemArray objectAtIndex:2] integerValue];
        num_mentions_string = [NSString stringWithFormat:@"%i", num_mentions];
        placename = [itemArray objectAtIndex:3];
        
        NSString *str_separator = @"_";

        NSString *annotation_filename = [NSString stringWithFormat:@"%@%@%@", lat_str, str_separator,long_str];

        [self.mapView setRegion:region];
        MapAnnotation  *allannotation   = [[MapAnnotation  alloc] init];
        
        CLLocationCoordinate2D  pinpoint;
        pinpoint.latitude = [[itemArray objectAtIndex:0] doubleValue];
        pinpoint.longitude =[[itemArray objectAtIndex:1] doubleValue];
        pinpoint.longitude =[[itemArray objectAtIndex:1] doubleValue];
        allannotation.coordinate = pinpoint;
        
        allannotation.title = placename;

        allannotation.coords_filename = annotation_filename;

        allannotation.subtitle = [NSString stringWithFormat:@"No. of extracts here: %li", (long)num_mentions];
        _mapView.delegate=self;
        [self.mapView addAnnotation:allannotation];
        
    }
    //NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    //NSString *intervalString = [NSString stringWithFormat:@"%f", timeInterval];
     
    // Do any additional setup after loading the view, typically from a nib.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"First Launch token");
        _text_view_nav_menu.title = @"Welcome to LitLong!";
    });
}

- (IBAction)setMapType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (void *)snippetdetail: (MapAnnotation *)closest_annotation
{
    NSString *location_filename = closest_annotation.coords_filename;

    NSString *location_file_contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:location_filename ofType:@"json" inDirectory:@"outputs"] encoding:NSUTF8StringEncoding error:nil];

    NSData *locationjsonData = [location_file_contents dataUsingEncoding:NSUTF8StringEncoding];
    //Problem with precision of double number of the lat and long numbers from the pinlocation.coordinate.latitute and ..longitude
    //the values in the original lat-long file read in for tha annotations is the same as the values in the filename of the new file to be read
    //however the pinlocation.oordinate gove a different number when returned
    
    if (!location_file_contents)
    {
        NSLog(@"File empty or not found!");
        //_text_view_nav_menu.title = placename;
        _snippet_text.text = @"Snippet Unknown";
        _title_text.text = @"Title Unknown";
        _author_text.text = @"Author Unknown";
        _url_text.text = @"No Link";
        _year_text.text = @"Year Unknown";
    }
    else
    {
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: locationjsonData options: NSJSONReadingMutableContainers error: &e];
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        } else {
            NSDictionary *response = [jsonArray objectAtIndex:0];
            NSUInteger elements = [jsonArray count];
            max_num_snippets = elements;
            snippet_number = 0;
            NSString *snippet = [response objectForKey:@"snippet"];
            NSString *title = [response objectForKey:@"title"];
            NSString *author = [response objectForKey:@"author"];
            NSString *url = [response objectForKey:@"url"];
            NSString *year = [response objectForKey:@"year"];
            NSString *placename = [response objectForKey:@"placename"];
            
            NSString *short_year = nil;
            
            if ([year length] >= 4)
                short_year = [year substringToIndex:4];
            else
                short_year = year;
            
            if (short_year == (id)[NSNull null]) {
                // year is null
                short_year = @"Undated";
            }
            if (author == (id)[NSNull null]) {
                // year is null
                author = @"Author Unknown";
            }
            if (title == (id)[NSNull null]) {
                // year is null
                title = @"Title Unknown";
            }
            if (snippet == (id)[NSNull null]) {
                // year is null
                snippet = @"Snippet Unknown";
            }
            if (url == (id)[NSNull null]) {
                // year is null
                url = @"No Link";
            }
            if (placename == (id)[NSNull null]) {
                // year is null
                placename = @"";
            }
            
            _text_view_nav_menu.title = placename;
            _snippet_text.text = snippet;
            _title_text.text = title;
            _author_text.text = author;
            _url_text.text = url;
            _year_text.text = short_year;
            
        }
    }
    return 0;
}

- (MKPointAnnotation *)closestAnnotation {
    // create variables you'll use to track the smallest distance measured and the
    // closest annotation
    MKPointAnnotation *closestAnnotation;
    CLLocationDistance smallestDistance = 9999999;
    
    // loop through your mapview's annotations (if you're using a different type of annotation,
    // just substitude it here)
    for (MKPointAnnotation *annotation in _mapView.annotations) {
        // create a location object from the coordinates for the annotation so you can easily
        // compare the two locations
        CLLocation *locationForAnnotation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        
        // calculate the distance between the user's location and the location you just created
        // from the annoatation's coordinates
        CLLocationDistance distanceFromUser = [_mapView.userLocation.location distanceFromLocation:locationForAnnotation];
        
        // if this calculated distance is smaller than the currently smallest distance, update the
        // smallest distance thus far as well as the closest annotation
        if (distanceFromUser < smallestDistance && distanceFromUser > 0) {
            smallestDistance = distanceFromUser;
            closestAnnotation = annotation;
        }
    }
    
    _snippet_text.text = closestAnnotation.title;
    _text_view_nav_menu.title = closestAnnotation.title;
    current_annotation = closestAnnotation;
    //NSString *distanceString = [NSString stringWithFormat: @"%f", smallestDistance];
    return closestAnnotation;
}

- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender {
    float spanX = 0.00725;//0.00725
    float spanY = 0.00725;//0.00725
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
    MKPointAnnotation *closest_annotation;
    closest_annotation = [self closestAnnotation];
    [self snippetdetail:(closest_annotation)];
    //_snippet_text.text = self.closestAnnotation.subtitle;

    //self.searchButton.hidden = YES;
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.searchButton.hidden = NO;
}
- (IBAction)goToOtherPlace:(UIButton *)sender {
    //NSLog(@"hello");
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = 55.9531;//Edinburgh
    region.center.longitude = -3.1889;//Edinburgh
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)next_snippet_pressed:(id)sender {

    if(snippet_number<max_num_snippets-1)
    {
    snippet_number = snippet_number+1;
        NSString *location_filename = current_annotation.coords_filename;
        NSString *location_file_contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:location_filename ofType:@"json" inDirectory:@"outputs"] encoding:NSUTF8StringEncoding error:nil];

        NSData *locationjsonData = [location_file_contents dataUsingEncoding:NSUTF8StringEncoding];

        
        if (!location_file_contents)
        {
            NSLog(@"File empty or not found!");
        }
        else
        {
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: locationjsonData options: NSJSONReadingMutableContainers error: &e];
            
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", e);
                //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:dist_to_pin_text message:@"No Text viewable" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                //[alertView show];
            } else {
                NSDictionary *response = [jsonArray objectAtIndex:snippet_number];
                //NSUInteger elements = [jsonArray count];
                NSString *snippet = [response objectForKey:@"snippet"];
                NSString *title = [response objectForKey:@"title"];
                NSString *author = [response objectForKey:@"author"];
                NSString *url = [response objectForKey:@"url"];
                NSString *year = [response objectForKey:@"year"];
                NSString *placename = [response objectForKey:@"placename"];
                NSString *short_year = nil;
                
                if ([year length] >= 4)
                    short_year = [year substringToIndex:4];
                else
                    short_year = year;
                
                if (short_year == (id)[NSNull null]) {
                    // year is null
                    short_year = @"Undated";
                }
                if (author == (id)[NSNull null]) {
                    // year is null
                    author = @"Author Unknown";
                }
                if (title == (id)[NSNull null]) {
                    // year is null
                    title = @"Title Unknown";
                }
                if (snippet == (id)[NSNull null]) {
                    // year is null
                    snippet = @"Snippet Unknown";
                }
                if (url == (id)[NSNull null]) {
                    // year is null
                    url = @"No Link";
                }
                if (placename == (id)[NSNull null]) {
                    // year is null
                    placename = @"";
                }
                
                _text_view_nav_menu.title = placename;
                _snippet_text.text = snippet;
                _title_text.text = title;
                _author_text.text = author;
                _url_text.text = url;
                _year_text.text = short_year;
                
            }
        }

    }
    else{
    }

}

- (IBAction)previous_snippet_pressed:(id)sender {

    if(snippet_number>0)
    {
        snippet_number = snippet_number-1;
        NSString *location_filename = current_annotation.coords_filename;
        
        NSString *location_file_contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:location_filename ofType:@"json" inDirectory:@"outputs"] encoding:NSUTF8StringEncoding error:nil];

        NSData *locationjsonData = [location_file_contents dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!location_file_contents)
        {
            NSLog(@"File empty or not found!");
        }
        else
        {
            NSError *e = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: locationjsonData options: NSJSONReadingMutableContainers error: &e];
            
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", e);
            } else {
                NSDictionary *response = [jsonArray objectAtIndex:snippet_number];
                //NSUInteger elements = [jsonArray count];
                NSString *snippet = [response objectForKey:@"snippet"];
                NSString *title = [response objectForKey:@"title"];
                NSString *author = [response objectForKey:@"author"];
                NSString *url = [response objectForKey:@"url"];
                NSString *year = [response objectForKey:@"year"];
                NSString *placename = [response objectForKey:@"placename"];
                NSString *short_year = nil;
                
                if ([year length] >= 4)
                    short_year = [year substringToIndex:4];
                else
                    short_year = year;
                
                if (short_year == (id)[NSNull null]) {
                    // year is null
                    short_year = @"Undated";
                }
                if (author == (id)[NSNull null]) {
                    // year is null
                    author = @"Author Unknown";
                }
                if (title == (id)[NSNull null]) {
                    // year is null
                    title = @"Title Unknown";
                }
                if (snippet == (id)[NSNull null]) {
                    // year is null
                    snippet = @"Snippet Unknown";
                }
                if (url == (id)[NSNull null]) {
                    // year is null
                    url = @"No Link";
                }
                if (placename == (id)[NSNull null]) {
                    // year is null
                    placename = @"";
                }
                
                _text_view_nav_menu.title = placename;
                _snippet_text.text = snippet;
                _title_text.text = title;
                _author_text.text = author;
                _url_text.text = url;
                _year_text.text = short_year;
                
            }
        }
        
    }
    else{
    }
}

//should really do this with a sorted array and do a binary tree search but this just brute forces the problem atm
-(NSArray *)get_nearest_lat_long:get_nearest_lat_long lat_array_in:(NSArray*)lat_array_in lon_array_in:(NSArray*)lon_array_in lat_val:(double) lat_val lon_val:(double)lon_val
{
    double closest_lat_val = 0.0;
    double closest_lon_val = 0.0;
    double difference_in_lat;
    double difference_in_lon;
    double Square_Of_Distance;
    int i;
    double smallestDistance = 9999999;
    NSMutableArray *closest_latlong_vals;
    
    for(i=0; i< lat_array_in.count;i=i+1)
    {
        difference_in_lat = fabs(lat_val - [lat_array_in[i] doubleValue]);
        difference_in_lon = fabs(lon_val - [lon_array_in[i] doubleValue]);
        Square_Of_Distance = pow(difference_in_lat,2) + pow(difference_in_lon,2);
        
        if (Square_Of_Distance < smallestDistance && Square_Of_Distance > 0) {
            smallestDistance = Square_Of_Distance;

            closest_lat_val = [lat_array_in[i] doubleValue];
            closest_lon_val = [lon_array_in[i] doubleValue];

        }
    }
    [closest_latlong_vals replaceObjectAtIndex:0 withObject:[NSNumber numberWithDouble:closest_lat_val]];
    [closest_latlong_vals replaceObjectAtIndex:1 withObject:[NSNumber numberWithDouble:closest_lon_val]];
    
    return closest_latlong_vals;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        //NSLog(@"Pressed for info");
    }
    CLLocation *pinLocation = [[CLLocation alloc] initWithLatitude:[(MKPointAnnotation*)[view annotation] coordinate].latitude longitude:[(MKPointAnnotation*)[view annotation] coordinate].longitude];
    
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    
    CLLocationDistance distance = [pinLocation distanceFromLocation:userLocation];
    
    NSString *dist_to_pin_text = [@"Distance to location " stringByAppendingString:[NSString stringWithFormat:@"%4.0fm", distance]];
 
    current_annotation = annotation;
    NSString *location_filename = [[NSString alloc] initWithString:[(MapAnnotation*)[view annotation] coords_filename]];
    
    NSString *location_file_contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:location_filename ofType:@"json" inDirectory:@"outputs"] encoding:NSUTF8StringEncoding error:nil];

    NSData *locationjsonData = [location_file_contents dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!location_file_contents)
    {
        NSLog(@"File empty or not found!");
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:dist_to_pin_text message:@"Snippet Text" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        //[alertView show];
    }
    else
    {
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: locationjsonData options: NSJSONReadingMutableContainers error: &e];
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:dist_to_pin_text message:@"No Text viewable" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alertView show];
        } else {
            NSDictionary *response = [jsonArray objectAtIndex:0];
            NSUInteger elements = [jsonArray count];
            max_num_snippets = elements;
            snippet_number = 0;
            NSString *snippet = [response objectForKey:@"snippet"];
            NSString *title = [response objectForKey:@"title"];
            NSString *author = [response objectForKey:@"author"];
            NSString *url = [response objectForKey:@"url"];
            NSString *year = [response objectForKey:@"year"];
            NSString *placename = [response objectForKey:@"placename"];
            NSString *short_year = nil;
            
            if ([year length] >= 4)
                short_year = [year substringToIndex:4];
            else
                short_year = year;
            
            if (short_year == (id)[NSNull null]) {
                // year is null
                short_year = @"Undated";
            }
            if (author == (id)[NSNull null]) {
                // year is null
                author = @"Author Unknown";
            }
            if (title == (id)[NSNull null]) {
                // year is null
                title = @"Title Unknown";
            }
            if (snippet == (id)[NSNull null]) {
                // year is null
                snippet = @"Snippet Unknown";
            }
            if (url == (id)[NSNull null]) {
                // year is null
                url = @"No Link";
            }
            if (placename == (id)[NSNull null]) {
                // year is null
                placename = @"";
            }
            
            _text_view_nav_menu.title = placename;
            _snippet_text.text = snippet;
            _title_text.text = title;
            _author_text.text = author;
            _url_text.text = url;
            _year_text.text = short_year;
            
            NSLog(@"After casting to screen \n");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:dist_to_pin_text message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];

        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    // Handle any custom annotations.
    else if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            //pinView.image = [UIImage imageNamed:@"book_icon.png"];//from: http://upload.wikimedia.org/wikipedia/commons/4/44/Book-of-myst.png
            pinView.image = [UIImage imageNamed:@"NibPin"];
            pinView.calloutOffset = CGPointMake(0, 32);
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            // Add an image to the left callout.
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_icon.png"]];
            pinView.leftCalloutAccessoryView = iconView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else if ([annotation isKindOfClass:[MapAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            //pinView.image = [UIImage imageNamed:@"book_icon.png"];//from: http://upload.wikimedia.org/wikipedia/commons/4/44/Book-of-myst.png
            pinView.image = [UIImage imageNamed:@"NibPin"];
            pinView.calloutOffset = CGPointMake(0, 32);
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            // Add an image to the left callout.
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_icon.png"]];
            pinView.leftCalloutAccessoryView = iconView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
