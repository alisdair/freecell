//
//  History.m
//  Freecell
//
//  Created by Alisdair McDiarmid on Sat Jul 26 2003.
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

#include <math.h>
#include <limits.h>
#import "History.h"

@implementation History

- initWithFile: (NSString *) newFile
{
    [super init];

    if (self)
    {
        file = [newFile retain];
        records = [[NSMutableArray arrayWithContentsOfFile: file] retain];
        if (records == nil)
            records = [[NSMutableArray array] retain];
    }

    return self;
}

- (void) dealloc
{
    [file release];
    [records release];
    [super dealloc];
}

// Overridden methods
//

- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView
{
    return [records count];
}

- tableView: (NSTableView *) tableView objectValueForTableColumn: (NSTableColumn *) column
        row: (NSInteger) row
{
    id object = [[self record: row] objectForKey: [column identifier]];

    if ([[column identifier] isEqual: @"result"])
        return [Result translateResultFromString: object];
    else if ([[column identifier] isEqual: @"duration"])
        return [object descriptionWithCalendarFormat: @"%H:%M:%S"
                                            timeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]
                                              locale: nil];
    else
        return object;
}

// Private methods
//

- (void) H_setRecords: (NSMutableArray *) newRecords
{
    [records release];
    records = [newRecords retain];
}

// Mutators
//

- (void) addRecordWithGameNumber: (NSNumber *) gameNumber
                          result: (Result *) result
                           moves: (unsigned) moves
                        duration: (NSTimeInterval) duration
                            date: (NSDate *) date
{
    NSDictionary *oldRecord;
    NSMutableDictionary *record;

    while ((oldRecord = [self recordWithGameNumber: gameNumber]))
        [records removeObject: oldRecord];

    record = [NSMutableDictionary dictionaryWithCapacity: 5];
    [record setObject: gameNumber forKey: @"gameNumber"];
    [record setObject: [result description] forKey: @"result"];
    [record setObject: [NSNumber numberWithUnsignedInt: moves] forKey: @"moves"];
    [record setObject: [NSDate dateWithTimeIntervalSinceReferenceDate: duration] forKey: @"duration"];
    [record setObject: date forKey: @"date"];
    
    [records addObject: record];    
    [records writeToFile: file atomically: YES];
}

- (void) clear
{
    [records removeAllObjects];
    [records writeToFile: file atomically: YES];    
}

- (void) sortByColumn: (NSString *) column withDescending: (BOOL) descending
{
    SEL compare = NSSelectorFromString([NSString stringWithFormat: @"%@Compare:", column]);

    [records sortUsingSelector: compare];
    if (descending)
        [records setArray: [[records reverseObjectEnumerator] allObjects]];
}

// Accessors
//

- (unsigned) numberOfRecordsWithResult: (Result *) result
{
    NSEnumerator *enumerator = [records objectEnumerator];
    NSDictionary *record;
    unsigned n = 0;

    while (record = [enumerator nextObject])
        if ([[record objectForKey: @"result"] isEqual: [result description]])
            n++;

    return n;
}

- (NSDictionary *) record: (NSUInteger) n
{
    if (n < [records count])
        return [records objectAtIndex: n];
    
    return nil;
}

- (NSNumber *) gameNumberForRecord: (NSUInteger) n
{
    return [[self record: n] objectForKey: @"gameNumber"];
}

- (NSDictionary *) recordWithGameNumber: (NSNumber *) gameNumber
{
    NSDictionary *record;
    NSEnumerator *enumerator = [records objectEnumerator];

    while (record = [enumerator nextObject])
        if ([[record objectForKey: @"gameNumber"] isEqual: gameNumber])
            return record;

    return nil;
}

- (NSDate *) shortestDuration
{
    NSDictionary *record;
    NSEnumerator *enumerator = [records objectEnumerator];
    NSDate *shortest = [NSDate distantFuture];
    
    while (record = [enumerator nextObject])
        if ([[record objectForKey: @"result"] isEqual: [[Result resultWithWin] description]])
            shortest = [[record objectForKey: @"duration"] earlierDate: shortest];

    return shortest;    
}

- (unsigned) shortestMoves
{
    NSDictionary *record;
    NSEnumerator *enumerator = [records objectEnumerator];
    unsigned shortest = UINT_MAX;
    
    while (record = [enumerator nextObject])
        if ([[record objectForKey: @"result"] isEqual: [[Result resultWithWin] description]])
            if ([[record objectForKey: @"moves"] unsignedIntValue] < shortest)
                shortest = [[record objectForKey: @"moves"] unsignedIntValue];
    if (shortest == UINT_MAX)
        shortest = 0;
    return shortest;
}

@end

// Category extension to dictionary

@interface NSDictionary (History)

- (NSComparisonResult) dateCompare: (NSDictionary *) other;
- (NSComparisonResult) durationCompare: (NSDictionary *) other;
- (NSComparisonResult) gameNumberCompare: (NSDictionary *) other;
- (NSComparisonResult) movesCompare: (NSDictionary *) other;
- (NSComparisonResult) resultCompare: (NSDictionary *) other;

@end

@implementation NSDictionary (History)

- (NSComparisonResult) dateCompare: (NSDictionary *) other
{
    return [(NSDate *) [self objectForKey: @"date"] compare: [other objectForKey: @"date"]];
}

- (NSComparisonResult) durationCompare: (NSDictionary *) other
{
    return [(NSDate *) [self objectForKey: @"duration"] compare: [other objectForKey: @"duration"]];
}

- (NSComparisonResult) gameNumberCompare: (NSDictionary *) other
{
    return [(NSNumber *) [self objectForKey: @"gameNumber"] compare: [other objectForKey: @"gameNumber"]];
}

- (NSComparisonResult) movesCompare: (NSDictionary *) other
{
    return [(NSNumber *) [self objectForKey: @"moves"] compare: [other objectForKey: @"moves"]];
}

- (NSComparisonResult) resultCompare: (NSDictionary *) other
{
    return [(NSString *) [self objectForKey: @"result"] compare: [other objectForKey: @"result"]];
}

@end
