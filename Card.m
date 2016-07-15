//
//  Card.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Sat Jul 05 2003.
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

#include <assert.h>
#import <stdio.h>
#import "Card.h"


@implementation Card

+ cardWithSuit: (Suit) newSuit rank: (Rank) newRank
{
    return [[[Card alloc] initWithSuit: newSuit rank: newRank] autorelease];
}

- initWithSuit: (Suit) newSuit rank: (Rank) newRank
{
    [super init];

    if (self)
    {
        suit = newSuit;
        rank = newRank;
    }
    
    return self;
}

- copyWithZone: (NSZone *) zone
{
    return [self retain];
}

// Overridden methods
//

- (NSUInteger) hash
//- (unsigned) hash
{
    // Suit ranges from 0 to 3; rank ranges from 1 (ACE) to 13 (KING).
    // This therefore returns a unique number between 0 and 51.
    return (suit * KING + (rank - ACE));
}

- (BOOL) isEqual: (id) other
{
    return ([self suit] == [other suit]
            && [self rank] == [other rank]);
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"%@ of %@",
        [self rankString], [self suitString]];
}

// Accessors
//

- (Suit) suit
{
    return suit;
}

- (NSString *) suitString
{
    NSString *suitToString[] = {
        @"Clubs", @"Diamonds", @"Hearts", @"Spades" };

    return suitToString[suit];
}

- (Rank) rank
{
    return rank;
}

- (NSString *) rankString
{
    NSString *rankToString[] = {
        @"None", @"Ace", @"Two", @"Three", @"Four",
        @"Five", @"Six", @"Seven", @"Eight", @"Nine",
        @"Ten", @"Jack", @"Queen", @"King" };

    return rankToString[rank];
}

- (BOOL) isRed
{
    return (suit == HEARTS || suit == DIAMONDS);
}

- (BOOL) isBlack
{
    return (suit == CLUBS || suit == SPADES);
}

- (BOOL) isSuccessorTo: (Card *) other
{
    // An ace is the only successor to a blank space
    if (other == nil)
        return (rank == ACE);

    // If our suits match, and my rank is one more than the other card, I am
    // its successor.
    return (suit == [other suit] && rank == [other rank] + 1);
}

- (BOOL) isPlayableOn: (Card *) other
{
    // Can play any card on a blank space
    if (other == nil)
        return YES;

    // Can't play a king on anything
    if (rank == KING)
        return NO;
    
    // If I am red and the other card is black, or vice versa, and my rank is
    // one less than the other card, I am playable on it.
    return ((([self isRed] && [other isBlack]) || ([self isBlack] && [other isRed]))
            && rank + 1 == [other rank]);
}

@end
