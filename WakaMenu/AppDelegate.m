//
//  AppDelegate.m
//  WakaMenu
//
//  Created by Hiroshi Horie on 2015/12/22.
//

#import "AppDelegate.h"

@interface AppDelegate () {
    NSString *_apiKey;
    NSStatusItem *_menu;
    NSTimer *_timer;
    NSURLSessionDataTask *_request;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    NSString *config = [NSString stringWithContentsOfFile:[@"~/.wakatime.cfg" stringByStandardizingPath]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    
    _apiKey = [self parseApiKeyFromString:config];

    NSLog(@"apiKey : %@", _apiKey);

    _menu = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _menu.title = @"WakaMenu";
    _menu.highlightMode = YES;
    _menu.button.target = self;
    _menu.button.action = @selector(menuAction:);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                              target:self
                                            selector:@selector(timerAction:)
                                            userInfo:nil
                                             repeats:YES];
    
    [self fetch];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [_timer invalidate];
}

#pragma mark - Methods

- (NSString *)parseApiKeyFromString:(NSString *)s {
    
    NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:@"api_key\\s*=\\s*([a-z0-9\\-]+)"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
    
    NSTextCheckingResult *match = [r firstMatchInString:s
                                                options:0
                                                  range:NSMakeRange(0, [s length])];
    if (match) {
        return [s substringWithRange:[match rangeAtIndex:1]];
    }
    
    return nil;
}

- (void)fetch {
    
    [_request cancel];
    
    NSString *start = @"today";
    NSString *end   = @"today";
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:@"https://wakatime.com/api/v1/users/current/summaries"];
    urlComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"api_key" value:_apiKey],
                                  [NSURLQueryItem queryItemWithName:@"start" value:start],
                                  [NSURLQueryItem queryItemWithName:@"end" value:end], ];
    
    NSLog(@"URL : %@", urlComponents.URL);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    _request = [session dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        
                                        if (!error) {
                                            
//                                            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                                            NSLog(@"%@", responseString);
                                        
                                            NSError *JSONError = nil;
                                            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
                                            if (!JSONError) {
                                                NSString *text = json[@"data"][0][@"grand_total"][@"text"];
                                                _menu.title = text;
                                            }
                                        
                                        }
                                        
                                    }];
    [_request resume];
}

#pragma mark - Actions

- (void)timerAction:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self fetch];
}

- (void)menuAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.wakatime.com/dashboard"]];
}

@end
