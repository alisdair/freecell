//
//  Game.m
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

#include <stdlib.h>
#include "vccRand.h"
#import "Game.h"
#import "Card.h"
#import "Table.h"
#import "GameView.h"
#import "GameController.h"

@interface Game (PrivateMethods)

- (void) G_deal;
- (void) G_setMove: (TableMove *) newTableMove;
- (void) G_attemptMove;
- (void) G_moreMoves;
- (void) G_autoStack;

@end

@implementation Game

+ gameWithView: (GameView *) newView
    controller: (GameController *) newController
    gameNumber: (NSNumber *) newGameNumber
{
    return [[[Game alloc] initWithView: newView
                            controller: newController
                            gameNumber: newGameNumber] autorelease];
}

- initWithView: (GameView *) newView
    controller: (GameController *) newController
          gameNumber: (NSNumber *) newGameNumber
{
    [super init];

    if (self)
    {
        view = newView;
        controller = newController;

        defaults = [NSUserDefaults standardUserDefaults];
        
        gameNumber = [newGameNumber retain];
        
        table = [[Table alloc] init];
        [self G_deal];
        
        result = [[Result resultWithUnplayed] retain];
        played = [[NSMutableArray alloc] init];
        undone = [[NSMutableArray alloc] init];

        [self setStartDate: [NSDate date]];
        inProgress = NO;

        [view setNeedsDisplay: YES];
    }
    return self;
}

- (void) dealloc
{
    [gameNumber release];
    [table release];
    [result release];
    [played release];
    [undone release];
    [move release];
    [hint release];
    [self setStartDate: nil];
    [self setEndDate: nil];
    [super dealloc];
}

// Private methods
//

- (void) G_deal
{
    TableLocation *deckTableLocation = [TableLocation locationWithType: DECK number: 0];
    NSMutableArray *deck = (NSMutableArray *) [table arrayForLocation: deckTableLocation];
    unsigned i, n;
	
	// Shuffle the deck
	vcpp_srand((unsigned long) [gameNumber doubleValue]);
	for (i = [deck count]; i > 0; i--)
	{
		unsigned j = vcpp_rand() % i;
		[deck exchangeObjectAtIndex: (i-1) withObjectAtIndex: j];
	}

    // Lay out table  
    n = [deck count];
    for (i = 0; i < n; i++)
    {
        TableLocation *column = [TableLocation locationWithType: COLUMN number: i % NUMBER_OF_COLUMNS];
        [table move: [TableMove moveFromSource: deckTableLocation toDestination: column]];
    }
}

- (void) G_setMove: (TableMove *) newMove
{
    [move release];
    move = [newMove copy];
}

- (void) G_attemptMove
{
    [move setCount: 0];

    if ([[move source] type] == COLUMN && [[move destination] type] == COLUMN)
    {
        unsigned emptyFreeCells = [table numberOfEmptyTableLocationType: FREE_CELL];
        unsigned emptyColumns   = [table numberOfEmptyTableLocationType: COLUMN];
        unsigned count;

        // The maximum number of cards which may be played with F empty free
        // cells is F + 1. However, this is doubled for every empty column,
        // except for the destination column.
        if (emptyColumns > 0 && [table cardNumber: 1
                                       atTableLocation: [move destination]] == nil)
            emptyColumns--;

        // If super-move is disabled, just pretend there are no empty free cells or columns.
        if ([defaults boolForKey: @"gameSuperMove"] == NO)
            emptyFreeCells = emptyColumns = 0;
        
        // So, the maximum number of cards is (F + 1) * 2^C, and
        // 2^C == 1 << C.
        for (count = (emptyFreeCells + 1) * (1 << emptyColumns); count > 0; count--)
        {
            unsigned try;

            // Check that the `count' cards are in valid sequence; break from the
            // loop if they are not.
            for (try = count; try > 1; try--)
                if (![[table cardNumber: try - 1 atTableLocation: [move source]] isPlayableOn:
                    [table cardNumber: try atTableLocation: [move source]]])
                    break;

            // The condition `try == 1' is YES iff the card sequence is valid.
            if (try == 1 &&
                [[table cardNumber: count atTableLocation: [move source]] isPlayableOn:
                    [table firstCardAtLocation: [move destination]]])
            {
                [move setCount: count];
                break;
            }
        }
    }
    else if ([[move destination] type] == STACK)
    {
        if ([[table firstCardAtLocation: [move source]] isSuccessorTo:
            [table firstCardAtLocation: [move destination]]])
            [move setCount: 1];
    }
    else if ([[move destination] type] == COLUMN)
    {
        if ([[table firstCardAtLocation: [move source]] isPlayableOn:
            [table firstCardAtLocation: [move destination]]])
            [move setCount: 1];
    }
    else if ([[move destination] type] == FREE_CELL)
    {
        if ([[table arrayForLocation: [move destination]] count] == 0)
            [move setCount: 1];
    }

    if ([move count] > 0)
    {
        if (inProgress == NO)
        {
            inProgress = YES;
            [self setStartDate: [NSDate date]];
        }
        [table move: move];
        [undone removeAllObjects];
        [played addObject: move];
        [controller moveMade];
    }

    [self G_setMove: nil];
    [view display];
    [self G_moreMoves];
    if ([defaults boolForKey: @"gameAutoStack"] == YES)
        [self G_autoStack];
}

- (void) G_moreMoves
{
    unsigned i;
    Card *card;

    for (i = 0; i < NUMBER_OF_STACKS; i++)
        if ([[table cardNumber: 1
                    atTableLocation: [TableLocation locationWithType: STACK number: i]] rank] != KING)
            break;

    if (i == NUMBER_OF_STACKS)
    {
        [self gameOverWithResult: [Result resultWithWin]];
        [controller gameOver];
        return;
    }

    if ([table numberOfEmptyTableLocationType: FREE_CELL] != 0)
        return;

    for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
    {
        unsigned j;

        card = [table firstCardAtLocation: [TableLocation locationWithType: FREE_CELL number: i]];
        for (j = 0; j < NUMBER_OF_STACKS; j++)
        {
            Card *other = [table firstCardAtLocation: [TableLocation locationWithType: STACK
                                                                          number: j]];
            if ([card isSuccessorTo: other])
                return;
        }

        for (j = 0; j < NUMBER_OF_COLUMNS; j++)
        {
            Card *other = [table firstCardAtLocation: [TableLocation locationWithType: COLUMN
                                                                          number: j]];
            if ([card isPlayableOn: other])
                return;
        }
    }

    for (i = 0; i < NUMBER_OF_COLUMNS; i++)
    {
        unsigned j;

        card = [table firstCardAtLocation: [TableLocation locationWithType: COLUMN number: i]];
        for (j = 0; j < NUMBER_OF_STACKS; j++)
        {
            Card *other = [table firstCardAtLocation: [TableLocation locationWithType: STACK
                                                                          number: j]];
            if ([card isSuccessorTo: other])
                return;
        }

        for (j = 0; j < NUMBER_OF_COLUMNS; j++)
        {
            Card *other = [table firstCardAtLocation: [TableLocation locationWithType: COLUMN
                                                                          number: j]];
            if ([card isPlayableOn: other])
                return;
        }
    }

    [self gameOverWithResult: [Result resultWithLoss]];
    [controller gameOver];
}

- (void) G_autoStack
{
    unsigned i, minimumStackedRank;
    TableLocation *source, *destination;
    Card *card, *other;

    minimumStackedRank = KING;
    for (i = 0; i < NUMBER_OF_STACKS; i++)
    {
        TableLocation *stack = [TableLocation locationWithType: STACK number: i];
        unsigned rank = [[table firstCardAtLocation: stack] rank];
        if (rank < minimumStackedRank)
            minimumStackedRank = rank;
    }

    for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
    {
        unsigned j;

        source = [TableLocation locationWithType: FREE_CELL number: i];
        card = [table firstCardAtLocation: source];

        for (j = 0; j < NUMBER_OF_STACKS; j++)
        {
            destination = [TableLocation locationWithType: STACK number: j];
            other = [table firstCardAtLocation: destination];
            if ([card isSuccessorTo: other] && [card rank] < minimumStackedRank + 3)
                goto makeMove;
        }
    }

    for (i = 0; i < NUMBER_OF_COLUMNS; i++)
    {
        unsigned j;

        source = [TableLocation locationWithType: COLUMN number: i];
        card = [table firstCardAtLocation: source];

        for (j = 0; j < NUMBER_OF_STACKS; j++)
        {
            destination = [TableLocation locationWithType: STACK number: j];
            other = [table firstCardAtLocation: destination];
            if ([card isSuccessorTo: other] && [card rank] < minimumStackedRank + 3)
                goto makeMove;
        }
    }

    // No safe auto-stack possible
    return;

makeMove:
    [self G_setMove: [TableMove moveFromSource: source toDestination: destination]];
    [self G_attemptMove];
}

// Mutators
//

- (void) setStartDate: (NSDate *) date
{
    [startDate release];
    startDate = [date retain];
}

- (void) setEndDate: (NSDate *) date
{
    [endDate release];
    endDate = [date retain];
}

- (void) undo
{
    if ([played count] > 0)
    {
        TableMove *undo = [TableMove reverseMove: [played lastObject]];
        
        [undone addObject: undo];
        [played removeLastObject];
        [table move: undo];

        [controller moveMade];
        [view setNeedsDisplay: YES];
    }
}

- (void) redo
{
    if ([undone count] > 0)
    {
        TableMove *redo = [TableMove reverseMove: [undone lastObject]];

        [played addObject: redo];
        [undone removeLastObject];
        [table move: redo];
        
        [controller moveMade];
        [view setNeedsDisplay: YES];
    }
}
    
- (void) clickedTableLocation: (TableLocation *) location
{
    // If a move hasn't been started yet, and the location clicked can be
    // moved from (it's a free cell or a column), start the move.
    if (move == nil)
    {
        if (([location type] == FREE_CELL || [location type] == COLUMN)
            && [table firstCardAtLocation: location] != nil)
        {
            [self G_setMove: [TableMove moveFromSource: location]];
            [view setNeedsDisplay: YES];
        }
        return;
    }

    // Otherwise, a move has been started, and this is the desired destination.
    [move setDestination: location];

    [self G_attemptMove];
}

- (void) doubleClickedTableLocation: (TableLocation *) source
{
    Card *card;
    unsigned i;

    [self G_setMove: [TableMove moveFromSource: source]];
    card = [table firstCardAtLocation: source];

    for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
    {
        TableLocation *freeCell = [TableLocation locationWithType: FREE_CELL number: i];
        
        if ([table firstCardAtLocation: freeCell] == nil)
        {
            [move setDestination: freeCell];
            break;
        }
    }

    [self G_attemptMove];
}

- (void) setHint
{
    Card *card, *other;
    TableLocation *source, *destination;
    int i;

    for (i = 0; i < NUMBER_OF_COLUMNS; i++)
    {
        unsigned j;

        source = [TableLocation locationWithType: COLUMN number: i];
        card = [table firstCardAtLocation: source];
        for (j = 0; j < NUMBER_OF_STACKS; j++)
        {
            destination = [TableLocation locationWithType: STACK number: j];
            other = [table firstCardAtLocation: destination];
            if ([card isSuccessorTo: other])
                goto foundHint;
        }
        for (j = 0; j < NUMBER_OF_COLUMNS; j++)
        {
            destination = [TableLocation locationWithType: COLUMN number: j];
            other = [table firstCardAtLocation: destination];
            if ([card isPlayableOn: other])
                goto foundHint;
        }
    }

    for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
    {
        unsigned j;

        source = [TableLocation locationWithType: FREE_CELL number: i];
        card = [table firstCardAtLocation: source];
        for (j = 0; j < NUMBER_OF_STACKS; j++)
        {
            destination = [TableLocation locationWithType: STACK number: j];
            other = [table firstCardAtLocation: destination];
            if ([card isSuccessorTo: other])
                goto foundHint;
        }
        for (j = 0; j < NUMBER_OF_COLUMNS; j++)
        {
            destination = [TableLocation locationWithType: COLUMN number: j];
            other = [table firstCardAtLocation: destination];
            if ([card isPlayableOn: other])
                goto foundHint;
        }
    }

    for (i = 0; i < NUMBER_OF_COLUMNS; i++)
    {
        unsigned j;

        source = [TableLocation locationWithType: COLUMN number: i];
        if ([table firstCardAtLocation: source] == nil)
            continue;
        
        for (j = 0; j < NUMBER_OF_FREE_CELLS; j++)
        {
            destination = [TableLocation locationWithType: FREE_CELL number: j];
            if ([table firstCardAtLocation: destination] == nil)
                goto foundHint;
        }
    }

    // No hint found.
    [self setHint: nil];

foundHint:
    [self setHint: [TableMove moveFromSource: source toDestination: destination]];
}

- (void) setHint: (TableMove *) newHint
{
    [hint release];
    hint = [newHint copy];
}

- (void) gameOverWithResult: (Result *) newResult
{
    [self setEndDate: [NSDate date]];
    [result release];
    result = [newResult copy];
    inProgress = NO;
}

// Accessors
//

- (Table *) table
{
    return table;
}

- (TableMove *) hint
{
    return hint;
}

- (NSNumber *) gameNumber
{
    return gameNumber;
}

- (NSDate *) startDate
{
    return startDate;
}

- (Result *) result
{
    return result;
}

- (unsigned) moves
{
    return [played count];
}

- (NSTimeInterval) duration
{
    return [endDate timeIntervalSinceDate: startDate];
}

- (BOOL) inProgress
{
    return inProgress;
}

- (BOOL) canUndo
{
    return (inProgress && [played count] > 0);
}

- (BOOL) canRedo
{
    return (inProgress && [undone count] > 0);
}

- (BOOL) isCardSelected: (Card *) card
{
    return ([card isEqual: [table firstCardAtLocation: [move source]]] ||
            [card isEqual: [table firstCardAtLocation: [hint source]]] ||
            [card isEqual: [table firstCardAtLocation: [hint destination]]]);
}

- (BOOL) isTableLocationSelected: (TableLocation *) location
{
    return ([location isEqual: [move source]] ||
            [location isEqual: [hint source]] ||
            [location isEqual: [hint destination]]);
}

- (NSArray *) movesList
{
    NSMutableArray *moves = [NSMutableArray arrayWithCapacity: [self moves]];
    NSEnumerator *enumerator = [played objectEnumerator];
    TableMove *tableMove;

    while (tableMove = [enumerator nextObject])
        [moves addObject: [tableMove description]];

    return [NSArray arrayWithArray: moves];
}

@end
