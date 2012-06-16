//
//  TableLocation.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Thu Jul 24 2003.
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

#import "TableLocation.h"


@implementation TableLocation

+ (TableLocation *) locationWithType: (TableLocationType) newType number: (unsigned short) newNumber
{
    return [[[TableLocation alloc] initWithType: newType number: newNumber] autorelease];
}

+ (TableLocation *) noLocation
{
    return [[[TableLocation alloc] initWithType: NONE number: 0] autorelease];
}

- (TableLocation *) initWithType: (TableLocationType) newType number: (unsigned short) newNumber
{
    [super init];

    if (self)
    {
        type = newType;
        number = newNumber;
    }

    return self;
}

- copyWithZone: (NSZone *) zone
{
    return [[TableLocation allocWithZone: zone] initWithType: type number: number];
}

// Overridden methods
//

- (BOOL) isEqual: (TableLocation *) other
{
    return (type == [other type] && number == [other number]);
}

- (NSString *) description
{
    NSString *typeToString[] = { @"None", @"Free Cell", @"Stack", @"Column", @"Deck" };

    return [NSString stringWithFormat: @"%@:%d", typeToString[type], number];
}

// Accessors
//

- (TableLocationType) type
{
    return type;
}

- (unsigned short) number
{
    return number;
}

@end
