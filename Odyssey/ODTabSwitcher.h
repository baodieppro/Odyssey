//
//  ODTabSwitcherView.h
//  Odyssey
//
//  Created by Terminator on 12/9/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODTabSwitcher : NSViewController
{
    IBOutlet NSTableView *_table;
}

+(instancetype)switcher;

-(IBAction)closeButtonClicked:(id)sender;
-(IBAction)addButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;
-(IBAction)cellClicked:(id)sender;




-(void)update;
-(void)showPopover;
-(void)runModal;
-(void)showSidebar;
-(BOOL)isSidebarOpen;

@end
