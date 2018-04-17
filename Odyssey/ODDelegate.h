//
//  ODDelegate.h
//  Odyssey
//
//  Created by Terminator on 4/6/17.
//  Copyright © 2017 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView, ODBookmarks, ODContentFilter, ODWindow, ODTabViewItem, ODPopoverWindow;

@interface ODDelegate : NSObject <NSApplicationDelegate> {
    @public
    NSMutableArray *_windows;
    BOOL _shouldUseYtdl;
    NSPanel *_modalDialog;
    ODPopoverWindow *_modalWindow;
}


- (void)openInNewWindow:(NSString *)path;
- (void)openInMainWindow:(NSString *)path newTab:(BOOL)value;
- (void)openInMainWindow:(NSString *)path newTab:(BOOL)newTab background:(BOOL)background;
- (void)openAddressListInTabs:(NSArray *)addressList newWindow:(BOOL)value; /* array of strings */
- (void)newWindowWithTabViewItem:(ODTabViewItem *)item;

- (WebView *)webView;    /* active webView of the main window */
@property (readonly) ODBookmarks *bookmarks;
@property (readonly) ODContentFilter *contentFilter;

- (IBAction)saveSessionMenuAction:(id)sender;
- (IBAction)manageSessionsMenuAction:(id)sender;

    /* Window */

- (IBAction)toggleTitlebar:(id)sender;
- (IBAction)toggleStatusbar:(id)sender;
- (IBAction)toggleTabView:(id)sender;
- (IBAction)toggleFindBanner:(id)sender;
- (IBAction)zoomVertically:(id)sender;

    /* Tabs */

- (IBAction)showTabs:(id)sender;
- (IBAction)openTab:(id)sender;
- (IBAction)closeTab:(id)sender;
- (IBAction)nextTab:(id)sender;
- (IBAction)previousTab:(id)sender;

    /* Navigation */

- (IBAction)goForward:(id)sender;
- (IBAction)goBackward:(id)sender;

    /* Page Zoom */

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)defaultZoom:(id)sender;
- (IBAction)zoomTextOnly:(id)sender;

    /* Stop/Reload */
- (IBAction)reloadPage:(id)sender;
- (IBAction)reloadFromOrigin:(id)sender;
- (IBAction)stopLoad:(id)sender;


- (IBAction)goTo:(id)sender;
- (IBAction)showDownloads:(id)sender;
- (IBAction)restartApplication:(id)sender;

// Private

- (ODTabViewItem *)_setUpWebTabItem;
- (void)_setUpWindow:(ODWindow *)window;


@end

@interface ODDelegate (ODDelegateExtensionMethods)

- (void)storeSession;
- (void)restoreSession;
- (NSArray *)sessionArray;
- (void)restoreSessionArray:(NSArray *)sessionArray;

- (NSPanel *)modalDialogWithView:(NSView *)view;

- (BOOL)canPlayWithMpv:(NSURL *)url;
- (void)playWithMpv:(NSURL *)url;
- (void)playWithMpvMenuItemClicked:(id)sender;// NSURL as representedObject
- (void)openInNewWindowMenuItemClicked:(id)sender;
- (void)openInNewTabMenuItemClicked:(id)sender;
- (void)searchImageMenuItemClicked:(id)sender;

@end