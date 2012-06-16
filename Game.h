//
//  Game.h
//  Freecell
//
//  Created by Alisdair McDiarmid on Thu Jul 03 2003.
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

#import <Foundation/Foundation.h>
#import "Result.h"
#import "Table.h"
#import "Card.h"
#import "TableLocation.h"

@class GameView;
@class GameController;

@interface Game : NSObject
{
    NSUserDefaults 	*defaults;
    Table 		*table;
    GameView		*view;
    GameController	*controller;
    TableMove		*move;
    TableMove		*hint;
    NSMutableArray	*played;
    NSMutableArray	*undone;
    NSNumber		*gameNumber;
    NSDate		*startDate;
    NSDate		*endDate;
    BOOL		inProgress;
    Result		*result;
}

+ gameWithView: (GameView *) newView
    controller: (GameController *) newController
    gameNumber: (NSNumber *) newGameNumber;
- initWithView: (GameView *) newView
    controller: (GameController *) newController
    gameNumber: (NSNumber *) newGameNumber;

// Mutators
//

- (void) setStartDate: (NSDate *) date;
- (void) setEndDate: (NSDate *) date;
- (void) undo;
- (void) redo;
- (void) clickedTableLocation: (TableLocation *) location;
- (void) doubleClickedTableLocation: (TableLocation *) source;
- (void) setHint;
- (void) setHint: (TableMove *) newHint;
- (void) gameOverWithResult: (Result *) newResult;

// Accessors
//

- (Table *) table;
- (TableMove *) hint;
- (NSNumber *) gameNumber;
- (NSDate *) startDate;
- (Result *) result;
- (unsigned) moves;
- (NSTimeInterval) duration;
- (BOOL) inProgress;
- (BOOL) canUndo;
- (BOOL) canRedo;
- (BOOL) isCardSelected: (Card *) card;
- (BOOL) isTableLocationSelected: (TableLocation *) location;
- (NSArray *) movesList;

@end
