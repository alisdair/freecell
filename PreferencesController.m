//
//  PreferencesController.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Fri Aug 1 2003.
//  Copyright (c) 2003 Alisdair McDiarmid.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
//  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  ALISDAIR MCDIARMID BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "PreferencesController.h"

@implementation PreferencesController

- (void) awakeFromNib
{
    NSData *data;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool: YES], @"gameSuperMove",
            [NSNumber numberWithBool: YES], @"gameAutoStack",
            nil]];
    
    [autoStack setState: [defaults boolForKey: @"gameAutoStack"]];

    [superMove setState: [defaults boolForKey: @"gameSuperMove"]];

    data = [defaults dataForKey: @"backgroundColour"];
    if (data)
    {
        NSColor *colour = [NSUnarchiver unarchiveObjectWithData: data];
        [backgroundColour setColor: colour];
    }
    [defaults synchronize];
}

- (IBAction) openWindow: (id) sender
{
    [window makeKeyAndOrderFront: self];
}

- (IBAction) autoStackClicked: (id) sender
{
    NSNumber *state = [NSNumber numberWithBool: [autoStack state] == NSOnState];
    [defaults setObject: state forKey: @"gameAutoStack"];
    [defaults synchronize];
}

- (IBAction) superMoveClicked: (id) sender
{
    NSNumber *state = [NSNumber numberWithBool: [superMove state] == NSOnState];
    [defaults setObject: state forKey: @"gameSuperMove"];
    [defaults synchronize];
}


- (IBAction) backgroundColourChosen: (id) sender
{
    NSColor *colour = [backgroundColour color];
    [defaults setObject: [NSArchiver archivedDataWithRootObject: colour] forKey: @"backgroundColour"];
    [defaults synchronize];
    [gameView setBackgroundColour: colour];
}

@end
