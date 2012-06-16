//
//  GameController.m
//  Freecell
//
//
//  Created by Alisdair McDiarmid on Tue Jul 08 2003.
//  Copyright (c) 2003 Alisdair McDiarmid. All rights reserved.
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

#include <unistd.h>
#include <time.h>
#include <stdlib.h>
#import "GameController.h"

@interface GameController (PrivateMethods)

- (void) GC_startGame;

@end

@implementation GameController

// Overridden methods
//

- (void) awakeFromNib
{
    srandom(time(NULL));

    [history awakeFromNib];
    [self updateTime: timer];
    [self moveMade];
    
    [window setReleasedWhenClosed: NO];
    [window setMiniwindowTitle: @"Freecell"];

    [view setController: self];
    [self newGame: self];
    timer = nil;
}

- (BOOL) applicationShouldHandleReopen: (NSApplication *) app hasVisibleWindows: (BOOL) flag
{
    if (flag == NO)
        [self newGame: self];

    return YES;
}

- (BOOL) windowShouldClose: (id) sender
{
    if ([game inProgress] == NO)
    {
        [self setGame: nil];
        return YES;
    }

    NSBeginAlertSheet(NSLocalizedString(@"closeTitle", @"windowShouldClose sheet title"),
                      NSLocalizedString(@"closeButton", @"Close button"),
                      NSLocalizedString(@"cancelButton", @"Cancel button"),
                      nil, window, self,
                      @selector(windowCloseSheetDidEnd:returnCode:contextInfo:),
                      NULL, NULL,
                      NSLocalizedString(@"closeText", @"windowShouldClose sheet text"));

    return NO;
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (id) sender
{
    if ([game inProgress] == NO)
        return NSTerminateNow;

    NSBeginAlertSheet(NSLocalizedString(@"closeTitle", @"windowShouldClose sheet title"),
                      NSLocalizedString(@"closeButton", @"Close button"),
                      NSLocalizedString(@"cancelButton", @"Cancel button"),
                      nil, window, self,
                      @selector(applicationTerminateSheetDidEnd:returnCode:contextInfo:),
                      NULL, NULL,
                      NSLocalizedString(@"closeText", @"windowShouldClose sheet text"));

    return NSTerminateLater;
}

- (BOOL) validateMenuItem: (NSMenuItem *) menuItem
{
    if ([menuItem tag] == 1)
        return [game canUndo];
    if ([menuItem tag] == 2)
        return [game canRedo];

    return YES;
}

- (void) windowWillClose: (NSNotification *) notification
{
    if ([[notification object] isEqual: window])
        [self setGame: nil];
}

// Action methods
//

- (IBAction) newGame: (id) sender
{
    [self playGameWithNumber: [NSNumber numberWithDouble: (double) random()]];
}

- (IBAction) retryGame: (id) sender
{
    [self GC_startGame];
}

- (IBAction) playGameNumber: (id) sender
{
    [NSApp stopModal];
    [self GC_startGame];
}

- (IBAction) openPlayNumberDialog: (id) sender
{
    if ([window attachedSheet] == nil)
    {
        [NSApp beginSheet: playNumberDialog
           modalForWindow: window
            modalDelegate: nil
           didEndSelector: nil
              contextInfo: nil];
        [NSApp runModalForWindow: window];
        // Wait for sheet to end...
        [NSApp endSheet: playNumberDialog];
        [playNumberDialog orderOut: self];
        [playNumberDialog close];
    }
}

- (IBAction) closePlayNumberDialog: (id) sender
{
    [NSApp stopModal];
}

- (IBAction) showHint: (id) sender
{
    [game setHint];
    if ([game hint])
    {
        [view display];
        sleep(1);
        [game setHint: nil];
        [view display];
    }
}

- (IBAction) undo: (id) sender
{
    [game undo];
}

- (IBAction) redo: (id) sender
{
    [game redo];
}

// Private methods
//

- (void) GC_startGame
{
    if ([window attachedSheet] != nil)
    {
        // Clear up the you-won/you-lost dialog if it's open
        if ([game inProgress] == NO)
        {
            [NSApp endSheet: [window attachedSheet]];
            [NSApp stopModal];
        }
        // Otherwise, we must already be checking whether or not to end the game
        else
            return;
    }

    if ([game inProgress] == YES)
        NSBeginAlertSheet(NSLocalizedString(@"newGameTitle", @"New game sheet title"),
                          NSLocalizedString(@"newGameButton", @"New game button"),
                          NSLocalizedString(@"cancelButton", @"Cancel button"),
                          nil, window, self,
                          @selector(startGameSheetDidEnd:returnCode:contextInfo:),
                          NULL, NULL,
                          NSLocalizedString(@"newGameText", "New game sheet text"));
    else
    {
        NSNumber *gameNumber = [NSNumber numberWithDouble: [gameNumberField doubleValue]];

        [self setGame: [Game gameWithView: view controller: self gameNumber: gameNumber]];
        [view setGame: game];
        
        [window setTitle: [NSString stringWithFormat:
            NSLocalizedString(@"gameWindowTitleFormat", @"Format for the title of the game window"), [gameNumberField stringValue]]];
        [window makeKeyAndOrderFront: self];
        [window makeMainWindow];
        
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self
                                               selector: @selector(updateTime:)
                                               userInfo: nil
                                                repeats: YES];
        [self updateTime: timer];
        [self moveMade];
    }
}

// Sheet handlers
//

- (void) startGameSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode
                  contextInfo: (void *) contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        [self setGame: nil];
        [self GC_startGame];
    }
}

- (void) windowCloseSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode
                        contextInfo: (void *) contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
        [window close];
}

- (void) applicationTerminateSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode
                             contextInfo: (void *) contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
        [window close];
    [NSApp replyToApplicationShouldTerminate: (returnCode == NSAlertDefaultReturn)];
}

- (void) gameWonSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode
                contextInfo: (void *) contextInfo
{
    if (returnCode == NSAlertAlternateReturn)
        [history openWindow: self];
    if (returnCode == NSAlertOtherReturn)
        [self newGame: self];
}

- (void) gameLostSheetDidEnd: (NSWindow *) sheet returnCode: (int) returnCode
                 contextInfo: (void *) contextInfo
{
    if (returnCode == NSAlertAlternateReturn)
        [self retryGame: self];
    if (returnCode == NSAlertOtherReturn)
        [self newGame: self];
}

// Timer stuff
//

- (void) updateTime: (NSTimer *) sender
{
    NSDate *current = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];
    NSDate *shortest = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];
    NSString *currentDuration;
    NSString *shortestDuration;
    
    if ([game inProgress])
    {
        current = [NSDate dateWithTimeIntervalSinceReferenceDate: [[NSDate date] timeIntervalSinceDate: [game startDate]]];
    }
    else if (![[game result] isEqual: [Result resultWithUnplayed]])
    {
        NSTimeInterval duration = [game duration];
        current = [NSDate dateWithTimeIntervalSinceReferenceDate: duration];
    }
    currentDuration = [current descriptionWithCalendarFormat: @"%H:%M:%S"
                                                     timeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]
                                                       locale: nil];
    if (history)
        shortest = [history shortestDuration];
    shortestDuration = [shortest descriptionWithCalendarFormat: @"%H:%M:%S"
                                 timeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]
                                   locale: nil];

    if (game != nil)
        [timeElapsed setStringValue: [NSString stringWithFormat: @"%@ (%@ %@)",
            currentDuration, NSLocalizedString(@"bestIs", "best is"), shortestDuration]];
}

- (void) moveMade
{
    unsigned currentMoves = [game moves];
    unsigned shortestMoves = [history shortestMoves];
    [movesMade setStringValue: [NSString stringWithFormat: @"%d %@ (%@ %d)",
        currentMoves, NSLocalizedString(@"moves", "moves"),
        NSLocalizedString(@"bestIs", "best is"), shortestMoves]];
}

// Mutators
//

- (void) playGameWithNumber: (NSNumber *) newGame
{
    [gameNumberField setDoubleValue: [newGame doubleValue]];
    [self GC_startGame];
}

- (void) setWindowSize: (NSSize) size
{
    NSRect frame = [window frame];
    frame.size = size;
    [window setFrame: frame display: YES];
}

- (void) recordGame
{
    [history addRecordWithGameNumber: [game gameNumber]
                              result: [game result]
                               moves: [game moves]
                            duration: [game duration]
                                date: [game startDate]];
}

- (void) setGame: (Game *) newGame
{
    if ([game inProgress])
        [game gameOverWithResult: [Result resultWithLoss]];

    if ([[game result] isEqual: [Result resultWithWin]] || [[game result] isEqual: [Result resultWithLoss]])
        [self recordGame];
    
    [game release];
    game = [newGame retain];
}

- (void) gameOver
{
    NSString *title, *defaultButton, *alternateButton, *message;
    SEL selector;
    Result *result = [game result];
    unsigned moves = [game moves];

    [timer fire];
    
    [timer invalidate];
    timer = nil;
    
    if ([result isEqual: [Result resultWithWin]])
    {
        title = NSLocalizedString(@"wonTitle", @"Won sheet title");
        defaultButton = NSLocalizedString(@"wonDefaultButton", @"Won sheet default button");
        alternateButton = NSLocalizedString(@"showHistoryButton", @"Show history button");
        message = NSLocalizedString(@"wonText", @"Won sheet text");
        selector = @selector(gameWonSheetDidEnd:returnCode:contextInfo:);
    }
    else if ([result isEqual: [Result resultWithLoss]])
    {
        title = NSLocalizedString(@"lostTitle", @"Lost sheet title");
        defaultButton = NSLocalizedString(@"lostDefaultButton", @"Lost sheet default button");
        alternateButton = NSLocalizedString(@"retryGameButton", @"Retry game button");
        message = NSLocalizedString(@"lostText", @"Lost sheet text");
        selector = @selector(gameLostSheetDidEnd:returnCode:contextInfo:);
    }
    else
    {
        return;
    }
    [self recordGame];

    NSBeginAlertSheet(title, defaultButton, alternateButton,
                      NSLocalizedString(@"newGameButton", @"New game button"),
                      window, self, selector, NULL, NULL, message, moves);
}

@end
