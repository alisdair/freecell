//
//  Table.m
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


#import "Table.h"
#import "Card.h"

@implementation Table

- init
{
    unsigned i;

    [super init];

    freeCells = [[NSMutableArray alloc] init];
    stacks    = [[NSMutableArray alloc] init];
    columns   = [[NSMutableArray alloc] init];
    decks     = [[NSMutableArray alloc] init];

    for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
        [freeCells addObject: [NSMutableArray array]];
    for (i = 0; i < NUMBER_OF_STACKS; i++)
        [stacks addObject: [NSMutableArray array]];
    for (i = 0; i < NUMBER_OF_COLUMNS; i++)
        [columns addObject: [NSMutableArray array]];
    for (i = 0; i < NUMBER_OF_DECKS; i++)
        [decks addObject: [NSMutableArray array]];

    for (i = ACE; i <= KING; i++)
    {
        // Use Windows suit ordering
        [[decks lastObject] addObject: [Card cardWithSuit: CLUBS rank: i]];
        [[decks lastObject] addObject: [Card cardWithSuit: DIAMONDS rank: i]];
        [[decks lastObject] addObject: [Card cardWithSuit: HEARTS rank: i]];
        [[decks lastObject] addObject: [Card cardWithSuit: SPADES rank: i]];
    }
    return self;
}

- (void) dealloc
{
    [freeCells release];
    [stacks release];
    [columns release];
    [decks release];
    
    [super dealloc];
}

// Mutators
//

- (void) move: (TableMove *) move
{
    NSMutableArray *source = (NSMutableArray *) [self arrayForLocation: [move source]];
    NSMutableArray *destination = (NSMutableArray *) [self arrayForLocation: [move destination]];
    unsigned long i, first, last;

    first = [source count] - [move count];
    last  = [source count];
    for (i = first; i < last; i++)
    {
        [destination addObject: [source objectAtIndex: first]];
        [source removeObjectAtIndex: first];
    }
}

// Accessors
//

- (NSArray *) arrayForLocation: (TableLocation *) location
{
    NSArray *locationType = [self arrayForLocationType: [location type]];
    return [locationType objectAtIndex: [location number]];
}

- (NSArray *) arrayForLocationType: (TableLocationType) locationType
{
    switch (locationType)
    {
        case NONE:	return nil;
        case FREE_CELL:	return freeCells;
        case STACK:	return stacks;
        case COLUMN:	return columns;
        case DECK:	return decks;
    }
    
    return nil;
}

- (unsigned) numberOfEmptyTableLocationType: (TableLocationType) locationType
{
    NSEnumerator *enumerator;
    NSArray *location;
    unsigned n = 0;
    
    enumerator = [[self arrayForLocationType: locationType] objectEnumerator];
    while (location = [enumerator nextObject])
        if ([location count] == 0)
            n++;

    return n;
}

- (Card *) cardNumber: (unsigned) n atTableLocation: (TableLocation *) location
{
    NSArray *array = [self arrayForLocation: location];

    if (n > [array count] || n == 0)
        return nil;
    
    return [array objectAtIndex: [array count] - n];
}

- (Card *) firstCardAtLocation: (TableLocation *) location
{
    return [self cardNumber: 1 atTableLocation: location];
}

@end
