//
//  ODDelegate+Extensions.m
//  Odyssey
//
//  Created by Terminator on 4/23/17.
//  Copyright © 2017 home. All rights reserved.
//

#import "ODDelegate.h"
#import "ODWindow.h"
#import "ODTabView.h"
#import "ODTabViewItem.h"
#import "ODPopoverWindow.h"

@import WebKit; 

#define SESSION_SAVE_PATH   [@"~/Library/Application Support/Odyssey/WebSession.plist" stringByExpandingTildeInPath]

#define TABLIST_KEY @"TabList"
#define WINDOW_RECT_KEY @"WindowContentRect"
#define IS_MINIATURIZED_KEY @"Miniaturized"
#define IS_FULLSCREEN_KEY @"Fullscreen"
#define SELECTED_TAB_KEY @"SelectedTabIndex"

#define TAB_ADDRESS_KEY @"Address"
#define TAB_TITLE_KEY @"Title"

@implementation ODDelegate (ODDelegateExtensionMethods)

#pragma mark - Session

-(void)storeSession
{
    NSMutableArray *sessionArray = [[NSMutableArray alloc] initWithCapacity:_windows.count];
//    NSMutableDictionary *window = [NSMutableDictionary new];
    
    for (ODWindow *window in _windows) {
        NSUInteger index = 0;
        NSDictionary *windowData;
        NSMutableArray *tabArray = [NSMutableArray new];
        for (ODTabViewItem *item in window.tabView.tabViewItems) {
            if (item.type == ODTabTypeDefault) {
                WebView *webView = (id)item.view;
                NSString *label;
                NSString *url;
                if (item.tag == 100) {
                    label = item.label;
                    url = item.representedObject;
                } else {
                    label = webView.mainFrameTitle;
                    url = webView.mainFrameURL;
                }
               
                               //if (!url) url = @"about:blank";
                
                NSDictionary *tab = @{TAB_TITLE_KEY: label, TAB_ADDRESS_KEY : url};
                [tabArray addObject:tab];
                if (item.state == ODTabStateSelected) {
                    index = [window.tabView indexOfTabViewItem:item];
                }
            }
        }
        windowData = @{TABLIST_KEY: tabArray, WINDOW_RECT_KEY: NSStringFromRect(window.frame),
                       IS_MINIATURIZED_KEY: [NSNumber numberWithBool:window.miniaturized],
                       IS_FULLSCREEN_KEY: [NSNumber numberWithBool:window.fullscreen], 
                       SELECTED_TAB_KEY: [NSNumber numberWithUnsignedInteger:index]};
        [sessionArray addObject:windowData];
    }
    
    [sessionArray writeToFile:SESSION_SAVE_PATH atomically:YES];
}

-(void)restoreSession
{
    NSMutableArray *sessionArray = [[NSMutableArray alloc] initWithContentsOfFile:SESSION_SAVE_PATH];
    NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask 
    | NSMiniaturizableWindowMask  ;

    for (NSDictionary *windowData in sessionArray) {
        ODWindow *window  = [[ODWindow alloc] initWithContentRect:NSRectFromString(windowData[WINDOW_RECT_KEY]) 
                                                        styleMask:styleMask 
                                                          backing:NSBackingStoreBuffered 
                                                            defer:YES];
        [self _setUpWindow:window];
        [window awakeFromNib];
        [window makeKeyAndOrderFront:nil];
        
        if ([windowData[IS_FULLSCREEN_KEY] boolValue]) {
            [window toggleFullScreen:nil];
        } else if ([windowData[IS_MINIATURIZED_KEY] boolValue]) {
            [window performMiniaturize:nil];
        }
        ODTabView *tabView = window.tabView;
        tabView.delegate = (id<ODTabViewDelegate>)self;
        NSMutableArray *tabArray = [NSMutableArray new];
        
        for (NSDictionary *tabData in windowData[TABLIST_KEY]) {
            ODTabViewItem *tabItem = [self _setUpWebTabItem];
            tabItem.label = tabData[TAB_TITLE_KEY];
            tabItem.representedObject = tabData[TAB_ADDRESS_KEY];
            [(id)tabItem.view setHostWindow:window];
            [tabArray addObject:tabItem];
        }
        [tabView addTabViewItems:tabArray];
        [tabView selectTabViewItemAtIndex:[windowData[SELECTED_TAB_KEY] unsignedIntegerValue]];
        //[window setTitle:tabView.selectedTabItem.label];
    }
}

#pragma mark - modal dialog

-(NSPanel *)modalDialogWithView:(NSView *)view
{
    if (!_modalWindow) {
        _modalWindow = [[ODPopoverWindow alloc] initWithContentRect:NSZeroRect 
                                                          styleMask:NSBorderlessWindowMask 
                                                            backing:NSBackingStoreBuffered defer:YES];
        [_modalWindow setWindowAppearance:1];
    }
    NSRect viewFrame = view.frame;
    NSRect frame = [[NSApp mainWindow] frame];
    NSPoint point = NSMakePoint(NSMinX(frame) + ((NSWidth(frame) - NSWidth(viewFrame)) / 2),
                                NSMinY(frame) + ((NSHeight(frame) - NSHeight(viewFrame)) / 2));
    [_modalWindow setFrame:viewFrame display:NO animate:NO];
    if (point.y >0) {
        [_modalWindow setFrameOrigin:point];
    } else {
        [_modalWindow center];
    }
    
    [_modalWindow setContentView:view];
    return _modalWindow;
    
//    if (!_modalDialog) {
//        NSInteger styleMask = NSTitledWindowMask | NSTexturedBackgroundWindowMask | NSUtilityWindowMask;
//        _modalDialog = [[NSPanel alloc] initWithContentRect:NSZeroRect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
//        [_modalDialog setBackgroundColor:[NSColor blackColor]];
//    } else {
//        
//        //[_modalDialog.contentView.subviews.firstObject removeFromSuperview];
//    }
//    NSRect viewFrame = view.frame;
//    NSRect frame = [[NSApp mainWindow] frame];
//    NSPoint point =  NSMakePoint(NSMinX(frame) + ((NSWidth(frame) - NSWidth(viewFrame)) / 2),
//                                 NSMinY(frame) + ((NSHeight(frame) - NSHeight(viewFrame)) / 2));
//    [_modalDialog setFrame:viewFrame display:NO animate:NO];
//    if (point.y > 0) {
//         [_modalDialog setFrameOrigin:point];
//    } else {
//        [_modalDialog center];
//    }
//   
//    //[_modalDialog.contentView addSubview:view];
//    [_modalDialog setContentView:view];
//    return _modalDialog;
}

#pragma mark - menuitem actions

-(void)openInNewTabMenuItemClicked:(id)sender
{
    NSURL *url = [sender representedObject];
    [self openInMainWindow:url.absoluteString newTab:YES background:YES];
}

-(void)openInNewWindowMenuItemClicked:(id)sender
{
     NSURL *url = [sender representedObject];
    [self openInNewWindow:url.absoluteString];
}

-(void)playWithMpvMenuItemClicked:(id)sender
{
    NSURL *url = [sender representedObject];
    [self playWithMpv:url];
}

#pragma mark - mpv support

-(BOOL)canPlayWithMpv:(NSURL *)url
{
#ifdef DEBUG
    NSLog(@"canPlayWithMpv: checking URL: %@", url);
#endif
    
    BOOL result = NO;
    NSString *string = url.absoluteString;
    NSRange range = [string rangeOfString:@"youtube.com/watch"];
    if (range.length) {
        result = YES;
    } else {
        range = [string rangeOfString:@"youtu.be/"];
        if (range.length) {
            result = YES;
        } else {
            range = [string rangeOfString:@"vimeo.com/"];
            if (range.length) {
                result = YES;
            }
        }
    }
    
    if (result) {
        _shouldUseYtdl = YES;
    } else {
        string = url.pathExtension;
        if ([string isEqualToString:@"webm"] 
            || [string isEqualToString:@"mp3"] 
            || [string isEqualToString:@"mp4"] 
            || [string isEqualToString:@"ogg"]) {
            
            _shouldUseYtdl = NO;
            result = YES;
        }
    }
    return result;
}

- (void)playWithMpv:(NSURL *)url {
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSURL *appURL = [sharedWorkspace URLForApplicationWithBundleIdentifier:@"io.mpv"];
    if (appURL) {
        NSString *ytdl = @"--no-ytdl";
        NSString *ytdlFormat = @"";
        if (_shouldUseYtdl) {
            ytdlFormat = @"--ytdl-format=bestvideo[height<=?1080][vcodec!=vp9]+bestaudio/best";
            NSEventModifierFlags flags = [NSEvent modifierFlags];
            switch (flags) {
                case NSAlternateKeyMask:
                    ytdlFormat = @"--ytdl-format=bestvideo[height<=?720][vcodec!=vp9]+bestaudio/best";
                    break;
                case NSCommandKeyMask:
                    ytdlFormat = @"--ytdl-format=bestvideo[height<=?480][vcodec!=vp9]+bestaudio/best";
                    break;
                case NSShiftKeyMask:
                    ytdlFormat = @"--ytdl-format=bestaudio/best";
                    break;
                default:
                    break;
            }
            ytdl = @"--ytdl";
            
        }
        NSArray *args = @[@"--loop=yes", ytdl, ytdlFormat, url.absoluteString];
        NSError *error = nil;
        [sharedWorkspace launchApplicationAtURL:appURL
                                                      options:NSWorkspaceLaunchAsync | NSWorkspaceLaunchNewInstance
                                                configuration:@{NSWorkspaceLaunchConfigurationArguments:args} 
                                                        error:&error];
        if (error) {
            
            NSLog(@"playWithMpv: [NSWorkspace sharedWorkspace] launchApplicationAtURL: failed \n%@", error.localizedDescription);
        }
        
    } else {
        
        NSString *cmd = [NSString stringWithFormat:@"/usr/local/bin/mpv --loop=yes \"%@\" &", url];
        const char *str = cmd.UTF8String;
        

        if (str) {
            system(str);
#ifdef DEBUG
            NSLog(@"playWithMpv: %@  cmd: %s", url, str);
#endif            
        } else {
#ifdef DEBUG            
            NSLog(@"playWithMpv: failed - cmd is NULL");
#endif            
        }

      
    }
    
}


@end