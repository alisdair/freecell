//
//  CardView.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Sun Jul 06 2003.
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

#import <AppKit/NSStringDrawing.h>
#import "CardView.h"

@implementation CardView

+ cardView
{
    return [[[CardView alloc] init] autorelease];
}

- init
{
    [super init];
    
    [self drawBlanks];
    [self drawCards];
    [self drawSelectedCards];
    
    return self;
}

- (void) drawBlanks
{
    NSImage *bonded = [NSImage imageNamed: @"bonded.png"];
    NSSize bondedSize = [bonded size];
    NSRect source;

    cardSize = NSMakeSize(bondedSize.width / 13, bondedSize.height / 5);
    
    // Placeholder blank
    blank = [[NSImage alloc] initWithSize: cardSize];
    source = NSMakeRect(0, bondedSize.height - 5 * cardSize.height,
                        cardSize.width, cardSize.height);
    
    [blank lockFocus];
    [bonded drawAtPoint: NSMakePoint(0, 0)
                    fromRect: source
                   operation: NSCompositeCopy
                    fraction: 1.0 ];
    [blank unlockFocus];
    
    // Selected blank (for placeholders and compositing selected cards)
    selectedBlank = [[NSImage alloc] initWithSize: cardSize];
    source = NSMakeRect(cardSize.width, bondedSize.height - 5 * cardSize.height,
                        cardSize.width, cardSize.height);
    
    [selectedBlank lockFocus];
    [bonded drawAtPoint: NSMakePoint(0, 0)
                    fromRect: source
                   operation: NSCompositeCopy
               fraction: 1.0];
    [selectedBlank unlockFocus];
}

- (void) drawCards
{
    NSImage *bonded = [NSImage imageNamed: @"bonded.png"];
    NSImage *card;
    NSRect source;
    NSSize bondedSize = [bonded size];
    NSMutableDictionary *dict;
    unsigned i;
    
    dict = [NSMutableDictionary dictionaryWithCapacity: 52];
    for (i = 0; i < NUMBER_OF_SUITS; i++)
    {
        unsigned j;
        for (j = ACE; j <= KING; j++)
        {
            card = [[[NSImage alloc] initWithSize: cardSize] autorelease];
            source = NSMakeRect((j - 1) * cardSize.width,
                                       bondedSize.height - (i + 1) * cardSize.height,
                                       cardSize.width, cardSize.height);
            
            [card lockFocus];
            [bonded drawAtPoint: NSMakePoint(0, 0)
                            fromRect: source
                           operation: NSCompositeCopy
                            fraction: 1.0];
            [card unlockFocus];
            
            [dict setObject: card forKey: [Card cardWithSuit: i rank: j]];
        }
    }
    
    cards = [dict retain];
}

- (void) drawSelectedCards
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 52];
    Card *card;
    NSEnumerator *enumerator = [cards keyEnumerator];

    while (card = [enumerator nextObject])
    {
        NSImage *image = [[cards objectForKey: card] copy];
        [image lockFocus];
        [selectedBlank drawAtPoint: NSMakePoint(0, 0) fromRect: NSZeroRect
                         operation: NSCompositeSourceAtop fraction: 0.5];
        [image unlockFocus];
        [dict setObject: image forKey: card];
    }
    selectedCards = [dict retain];
}


- (NSImage *) imageForCard: (Card *) card selected: (BOOL) isSelected
{
    if (card == nil)
        return isSelected? selectedBlank: blank;
    
    return [isSelected? selectedCards: cards objectForKey: card];
}

- (NSSize) size
{
    return cardSize;
}

- (unsigned) overlap
{
    return cardSize.height/3;
}

- (unsigned) smallOverlap
{
    return cardSize.height/4.75;
}

@end
