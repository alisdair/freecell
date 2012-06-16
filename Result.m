//
//  Result.m
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

#import "Result.h"

@implementation Result

+ (NSString *) translateResultFromString: (NSString *) string
{
    if ([string isEqual: @"Win"])
        return NSLocalizedString(@"resultWin", @"Result: win");
    else if ([string isEqual: @"Loss"])
        return NSLocalizedString(@"resultLoss", @"Result: loss");
    else
        return @"Invalid";
}

+ resultWithUnplayed
{
    return [[[Result alloc] initWithResult: UNPLAYED] autorelease];
}

+ resultWithLoss
{
    return [[[Result alloc] initWithResult: LOSS] autorelease];
}

+ resultWithWin
{
    return [[[Result alloc] initWithResult: WIN] autorelease];
}

- initWithResult: (ResultValue) newResult
{
    [super init];

    if (self)
        result = newResult;

    return self;
}

- copyWithZone: (NSZone *) zone
{
    return [[Result allocWithZone: zone] initWithResult: result];
}

- (NSString *) description
{
    switch (result)
    {
        default:
        case UNPLAYED:
            return @"Unplayed";
        case LOSS:
            return @"Loss";
        case WIN:
            return @"Win";
    }
}

- (BOOL) isEqual: (Result *) other
{
    return (result == [other result]);
}

// Accessor methods
//

- (ResultValue) result
{
    return result;
}

@end
