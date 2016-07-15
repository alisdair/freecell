//
//  GameView.m
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

#import "GameView.h"
#import "Game.h"
#import "Card.h"
#import "CardView.h"
#import "Table.h"

@implementation GameView

- (id) initWithFrame: (NSRect) frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // Default colour is a nice shade of green
        NSColor *colour = [NSColor colorWithCalibratedRed: 0.2 green: 0.4
                                                     blue: 0.1 alpha: 1.0];
        NSData *data = [NSArchiver archivedDataWithRootObject: colour];

        // Set the default
        [defaults registerDefaults:
            [NSDictionary dictionaryWithObjectsAndKeys:
                data, @"backgroundColour", nil]];

        // Then try to read the preference
        data = [defaults dataForKey: @"backgroundColour"];
        if (data)
            colour = [NSUnarchiver unarchiveObjectWithData: data];
        [defaults synchronize];

        // And set the coloour
        [self setBackgroundColour: colour];
    }

    return self;
}

- (void) dealloc
{
    [game release];
    [cardView release];
    [super dealloc];
}

- (void) drawRect: (NSRect) rect
{
    int i;
    NSRect frame = [self frame];

    [backgroundColour set];
    [NSBezierPath fillRect: frame];
    
    if (game == nil || cardView == nil)
        return;

    for (i = 0; i < NUMBER_OF_FREE_CELLS; i++)
    {
        TableLocation *location = [TableLocation locationWithType: FREE_CELL number: i];
        NSPoint origin = NSMakePoint(edgeMargin + (cardWidth + margin) * i,
                                     frame.size.height - edgeMargin - cardHeight);
        Card *card = [table firstCardAtLocation: location];
        BOOL selected = [game isTableLocationSelected: location];
        NSImage *image = [cardView imageForCard: card selected: selected];
        NSCompositingOperation operation;
        
        if (card == nil && !selected)
            operation = NSCompositePlusLighter;
        else
            operation = NSCompositeSourceOver;
                
        //[image compositeToPoint: origin
        //             operation: operation
        //               fraction: card == nil? 0.5 : 1.0 ];
        [ image drawAtPoint: origin fromRect: frame operation: operation
                   fraction: card == nil ? 0.5 : 1.0 ];
    }
    
    for (i = 0; i < NUMBER_OF_STACKS; i++)
    {
        TableLocation *location = [TableLocation locationWithType: STACK number: i];
        NSPoint origin = NSMakePoint(edgeMargin + (cardWidth + margin) * (i + 4),
                                     frame.size.height - edgeMargin - cardHeight);
        Card *card = [table firstCardAtLocation: location];
        BOOL selected = [game isTableLocationSelected: location];
        NSImage *image = [cardView imageForCard: card selected: selected];
        NSCompositingOperation operation;
        
        if (card == nil && !selected)
            operation = NSCompositePlusLighter;
        else
            operation = NSCompositeSourceOver;
        
        //[image compositeToPoint: origin
        //              operation: operation
        //               fraction: card == nil? 0.25 : 1.0 ];
        [ image drawAtPoint: origin fromRect: frame operation: operation
                   fraction: card == nil ? 0.25 : 1.0 ];
   }

    for (i = 0; i < NUMBER_OF_COLUMNS; i++)
    {
        TableLocation *location = [TableLocation locationWithType: COLUMN number: i];
        NSArray *column = [table arrayForLocation: location];
        NSEnumerator *enumerator = [column objectEnumerator];
        Card *card;
        int row;
        int count = [column count];
        unsigned maxHeight = 19 * smallOverlap;
        unsigned short o;

        o = (count * overlap > maxHeight)? maxHeight/count: overlap;

        for (row = 0; card = [enumerator nextObject]; row++)
        {
            NSPoint origin = NSMakePoint(edgeMargin + (cardWidth + margin) * i,
                                         frame.size.height - edgeMargin
                                         - (cardHeight + margin) * 2 - o * row);
            NSImage *image = [cardView imageForCard: card selected: [game isCardSelected: card]];
            //[image compositeToPoint: origin operation: NSCompositeSourceOver];
            [ image drawAtPoint: origin fromRect: frame operation: NSCompositeSourceOver
                       fraction: 1.0 ];
       }

        // If the column is empty and selected, draw the selected image
        if (row == 0 && [game isTableLocationSelected: [TableLocation locationWithType: COLUMN number: i]])
        {
            NSPoint origin = NSMakePoint(edgeMargin + (cardWidth + margin) * i,
                                         frame.size.height - edgeMargin
                                         - (cardHeight + margin) * 2);
            NSImage *image = [cardView imageForCard: nil selected: YES];
            //[image compositeToPoint: origin operation: NSCompositePlusDarker fraction: 0.5];
            [ image drawAtPoint: origin fromRect: frame operation: NSCompositePlusDarker
                       fraction: 0.5 ];
        }
    }
}

- (void) mouseDown: (NSEvent *) event
{
    TableLocation *location = nil;
    NSPoint pos = [event locationInWindow];
    NSRect frame = [self frame];

    if (pos.x > edgeMargin && pos.x < frame.size.width - edgeMargin
        && pos.y < frame.size.height - edgeMargin)
    {
        if (pos.y >= frame.size.height - cardHeight - margin)
        {
            if (pos.x < edgeMargin + (cardWidth + margin) * NUMBER_OF_FREE_CELLS)
                location = [TableLocation locationWithType: FREE_CELL
                                               number: (pos.x - edgeMargin)/(cardWidth + margin)];
            else
                location = [TableLocation locationWithType: STACK
                                               number: (pos.x - edgeMargin)/(cardWidth + margin) - 4];
        }
        else if (pos.y <= frame.size.height - cardHeight - margin * 2)
            location = [TableLocation locationWithType: COLUMN
                                           number: (pos.x - edgeMargin)/(cardWidth + margin)];
    }

    if (location)
    {
        // Take any even number of clicks as a double-click. This allows a
        // quad-click to be understood as two double-clicks in quick succession,
        // which makes perfect UI sense in this case.
        if (([event clickCount] % 2) == 0)
            [game doubleClickedTableLocation: location];
        else
            [game clickedTableLocation: location];
    }
}

// Mutators
//

- (void) setGame: (Game *) newGame
{
    [game release];
    game = [newGame retain];
    table = [game table];
    [self setNeedsDisplay: YES];
}

- (void) setController: (GameController *) newController;
{
    controller = newController;
    [self setCardView: [CardView cardView]];
}

- (void) setCardView: (CardView *) newCardView
{
    NSSize size;

    [newCardView retain];
    [cardView release];
    cardView = newCardView;

    // Calculate frame size
    
    margin = 8;
    edgeMargin = 2 * margin;
    overlap = [cardView overlap];
    smallOverlap = [cardView smallOverlap];
    cardWidth = [cardView size].width;
    cardHeight = [cardView size].height;

    size = NSMakeSize(edgeMargin + (cardWidth + margin) * 8 - margin + edgeMargin,
                            edgeMargin + (cardHeight + margin) * 2 + smallOverlap * 18 + edgeMargin);

    [controller setWindowSize: NSMakeSize(size.width, size.height + 22)];
    [self setNeedsDisplay: YES];
}

- (void) setBackgroundColour: (NSColor *) colour
{
    [colour retain];
    [backgroundColour release];
    backgroundColour = colour;
    [self setNeedsDisplay: YES];
}

@end