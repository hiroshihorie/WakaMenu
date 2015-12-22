//
//  main.m
//  WakaMenu
//
//  Created by Hiroshi Horie on 2015/12/22.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication * app = [NSApplication sharedApplication];
        id delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    
    return EXIT_SUCCESS;
}
