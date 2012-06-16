//
//  HistoryController.h
//  Freecell
//
//  Created by Alisdair McDiarmid on Tue Jul 29 2003.
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

#import <Cocoa/Cocoa.h>
#import "Result.h"
#import "History.h"

@class GameController;

@interface HistoryController : NSObject
{
    IBOutlet NSTextField	*gamesLost;
    IBOutlet NSTextField	*gamesPlayed;
    IBOutlet NSTextField	*gamesWon;
    IBOutlet NSButton		*retryGame;
    IBOutlet NSTableView	*tableView;
    IBOutlet NSWindow		*window;
    IBOutlet NSTableColumn	*lastPlayedColumn;
    GameController          *gameController;
    History                 *history;
    NSString                *sortColumn;
    BOOL                    sortDescending;
}

// Action methods
//

- (IBAction) clear: (id) sender;
- (IBAction) openWindow: (id) sender;
- (IBAction) retryGame: (id) sender;

// Mutators
//

- (void) addRecordWithGameNumber: (NSNumber *) gameNumber
                          result: (Result *) result
                           moves: (unsigned short) moves
                        duration: (NSTimeInterval) duration
                            date: (NSDate *) date;

- (NSDate *) shortestDuration;
- (unsigned) shortestMoves;
- (unsigned) numberOfGamesWon;

@end
