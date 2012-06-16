//
//  GameController.h
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

#import <Cocoa/Cocoa.h>
#import "Result.h"
#import "GameView.h"
#import "Game.h"
#import "HistoryController.h"
#import "CardView.h"

@interface GameController : NSObject
{
    IBOutlet GameView       *view;
    IBOutlet NSWindow       *window;
    IBOutlet NSPanel        *donatePanel;
    IBOutlet NSPanel        *playNumberDialog;
    IBOutlet NSTextField    *gameNumberField;
    IBOutlet NSTextField    *timeElapsed;
    IBOutlet NSTextField    *movesMade;
    Game                    *game;
    CardView                *cardView;
    HistoryController       *history;
    NSTimer                 *timer;
}

// Action methods
//

- (IBAction) newGame: (id) sender;
- (IBAction) retryGame: (id) sender;
- (IBAction) playGameNumber: (id) sender;
- (IBAction) openPlayNumberDialog: (id) sender;
- (IBAction) closePlayNumberDialog: (id) sender;
- (IBAction) showHint: (id) sender;
- (IBAction) undo: (id) sender;
- (IBAction) redo: (id) sender;
- (IBAction) donate: (id) sender;
- (IBAction) notYet: (id) sender;
- (IBAction) haveDonated: (id) sender;

// Timer stuff
//

- (void) updateTime: (NSTimer *) timer;
- (void) moveMade;

// Mutators
//

- (void) playGameWithNumber: (NSNumber *) newGame;
- (void) setGame: (Game *) newGame;
- (void) setWindowSize: (NSSize) size;
- (void) gameOver;

@end
