//
//  Drive.h
//  
//
//  Created by Marty Lavender on 6/25/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Drive : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSOrderedSet *locations;
@end

@interface Drive (CoreDataGeneratedAccessors)

- (void)insertObject:(Location *)value inLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationsAtIndex:(NSUInteger)idx;
- (void)insertLocations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationsAtIndex:(NSUInteger)idx withObject:(Location *)value;
- (void)replaceLocationsAtIndexes:(NSIndexSet *)indexes withLocations:(NSArray *)values;
- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSOrderedSet *)values;
- (void)removeLocations:(NSOrderedSet *)values;
@end
