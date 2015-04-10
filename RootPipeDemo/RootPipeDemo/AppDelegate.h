//
//  AppDelegate.h
//  RootPipeDemo
//
//  Created by Kramer on 4/10/15.
//  Copyright (c) 2015 Shmoopi LLC. All rights reserved.
//  Icon from:  http://findicons.com/icon/58296/mac_red?id=58328
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// Inputs
@property (weak) IBOutlet NSTextField *pathToFile;
@property (weak) IBOutlet NSTextField *pathToOutput;
@property (weak) IBOutlet NSTextField *filePermissions;
@property (weak) IBOutlet NSTextField *fileOwner;
@property (weak) IBOutlet NSTextField *fileGroup;

// Open Panel
- (IBAction)browseToFileInput:(id)sender;
// Save Panel
- (IBAction)browseToFileOutput:(id)sender;

// Main action
- (IBAction)createFile:(id)sender;

@end

