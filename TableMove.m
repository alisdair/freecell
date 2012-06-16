//
//  TableMove.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Fri Jul 11 2003.
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


#import "TableMove.h"


@implementation TableMove

+ moveFromSource: (TableLocation *) newSource
{
    return [[[TableMove alloc] initWithSource: newSource destination: [TableLocation noLocation]] autorelease];
}

+ moveFromSource: (TableLocation *) newSource toDestination: (TableLocation *) newDestination
{
    return [[[TableMove alloc] initWithSource: newSource
                                 destination: newDestination
                                       count: 1] autorelease];
}

+ reverseMove: (TableMove *) move
{
    return [[[TableMove alloc] initWithSource: move->destination
                                 destination: move->source
                                       count: move->count] autorelease];
}

- init
{
    return [self initWithSource: [TableLocation noLocation]
                    destination: [TableLocation noLocation]
                          count: 0];
}

- initWithSource: (TableLocation *) newSource destination: (TableLocation *) newDestination
{
    return [self initWithSource: newSource
                    destination: newDestination
                          count: 1];
}

- initWithSource: (TableLocation *) newSource destination: (TableLocation *) newDestination
           count: (unsigned) newCount
{
    [super init];

    if (self)
    {
        source = [newSource copy];
        destination = [newDestination copy];
        
        if ([source type] == NONE || [destination type] == NONE)
            count = 0;
        else
            count = newCount;
    }

    return self;
}

- (void) dealloc
{
    [self setSource: nil];
    [self setDestination: nil];
    [super dealloc];
}

- copyWithZone: (NSZone *) zone
{
    return [[TableMove allocWithZone: zone] initWithSource: source
                                              destination: destination
                                                    count: count];
}

// Overridden methods
//

- (NSString *) description
{
    return [NSString stringWithFormat: @"Source = %@; Destination = %@",
        source, destination];
}

// Mutators
//

- (void) setSource: (TableLocation *) newSource
{
    [source release];
    source = [newSource copy];
}

- (void) setDestination: (TableLocation *) newDestination
{
    [destination release];
    destination = [newDestination copy];
}

- (void) setCount: (unsigned) newCount
{
    count = newCount;
}

// Accessors
//

- (TableLocation *) source
{
    return source;
}

- (TableLocation *) destination
{
    return destination;
}

- (unsigned) count
{
    return count;
}

@end
