//
//  Table.h
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
#import "Card.h"
#import "TableMove.h"
#import "TableLocation.h"

enum {
    NUMBER_OF_COLUMNS = 8, NUMBER_OF_STACKS = 4, NUMBER_OF_FREE_CELLS = 4,
    NUMBER_OF_DECKS = 1
};

@interface Table : NSObject
{
    NSMutableArray	*columns;
    NSMutableArray	*stacks;
    NSMutableArray	*freeCells;
    NSMutableArray	*decks;
}

// Mutators
//

- (void) move: (TableMove *) move;

// Accessors
//

- (NSArray *) arrayForLocation: (TableLocation *) location;
- (NSArray *) arrayForLocationType: (TableLocationType) locationType;
- (unsigned) numberOfEmptyTableLocationType: (TableLocationType) locationType;
- (Card *) cardNumber: (unsigned) n atTableLocation: (TableLocation *) location;
- (Card *) firstCardAtLocation: (TableLocation *) location;

@end
