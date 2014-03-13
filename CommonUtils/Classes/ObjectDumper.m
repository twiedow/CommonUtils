//
//  ObjectDumper.m
//  CommonUtils
//
//  Created by twiedow on 13.03.14.
//  Copyright (c) 2014 twiedow. All rights reserved.
//

#import "ObjectDumper.h"
#import <objc/runtime.h>


@interface ObjectDumper ()

+ (NSString *)indentationStringForIndentationSpaces:(NSInteger)indentationSpaces;

@end


@interface DumpLine : NSObject

@property (strong, nonatomic) NSString *fieldName;
@property (strong, nonatomic) NSString *fieldValue;
@property NSInteger indentationLevel;

+ (DumpLine *)dumpLineWithFieldName:(NSString *)fieldName withFieldValue:(NSString *)fieldValue withIndentationLevel:(NSInteger)indentationLevel;

@end


@implementation DumpLine

+ (DumpLine *)dumpLineWithFieldName:(NSString *)fieldName withFieldValue:(NSString *)fieldValue withIndentationLevel:(NSInteger)indentationLevel {
  DumpLine *dumpLine = [[DumpLine alloc] init];
  dumpLine.fieldName = fieldName;
  dumpLine.fieldValue = fieldValue;
  dumpLine.indentationLevel = indentationLevel;
  return dumpLine;
}


- (NSString*) description {
  return [NSString stringWithFormat:@"%@%@=%@", [ObjectDumper indentationStringForIndentationSpaces:self.indentationLevel*2], self.fieldName, self.fieldValue];
}

@end


@implementation ObjectDumper


+ (NSString *)indentationStringForIndentationSpaces:(NSInteger)indentationSpaces {
  NSMutableString *string = [NSMutableString stringWithCapacity:indentationSpaces];
  for (NSInteger i = 0; i < indentationSpaces; i++)
    [string appendString:@" "];
  return string;
}


+ (NSArray *)dumpProperties:(id)instance classType:(Class)classType atIndentationLevel:(NSInteger)indentationLevel {
  unsigned int count;
  objc_property_t *propList = class_copyPropertyList(classType, &count);

  NSMutableArray *dumpLines = [NSMutableArray array];

  for (int i = 0; i < count; i++) {
    objc_property_t property = propList[i];

    const char *propName = property_getName(property);
    NSString *propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];

    if (propName) {
			@try {
				id value = [instance valueForKey:propNameString];
				NSString *className = [NSString stringWithCString:class_getName([value class]) encoding:NSASCIIStringEncoding];

				if ([className rangeOfString:@"NS"].location != NSNotFound) {
					[dumpLines addObject:[DumpLine dumpLineWithFieldName:propNameString withFieldValue:[value description] withIndentationLevel:indentationLevel]];
				}
				else
					[ObjectDumper dumpRecursive:value withName:propNameString atIndentationLevel:indentationLevel+1];
			}
			@catch (NSException *exception) {
				NSLog(@"Can't get value for property %@ through KVO\n", propNameString);
			}
    }
  }
  free(propList);

  Class superClass = class_getSuperclass(classType);
  if (superClass != nil && ![superClass isEqual:[NSObject class]]) {
    NSString *superClassName = [NSString stringWithCString:class_getName(superClass) encoding:NSASCIIStringEncoding];

    if ([superClassName rangeOfString:@"NS"].location == NSNotFound)
      [dumpLines addObject:[ObjectDumper dumpProperties:instance classType:superClass atIndentationLevel:indentationLevel]];
  }

  return dumpLines;
}


+ (NSArray *)dumpRecursive:(id)instance withName:(NSString *)name atIndentationLevel:(NSInteger)indentationLevel {
  NSMutableArray *dumpLines = [NSMutableArray array];

  NSString *className = [NSString stringWithCString:class_getName([instance class]) encoding:NSASCIIStringEncoding];

  if ([instance isKindOfClass:[NSArray class]] || [instance isKindOfClass:[NSSet class]]) {
    [dumpLines addObject:[DumpLine dumpLineWithFieldName:name withFieldValue:[[instance class] description] withIndentationLevel:indentationLevel]];

    NSInteger counter = 0;

    for (id entry in instance) {
      [dumpLines addObjectsFromArray:[ObjectDumper dumpRecursive:entry withName:[NSString stringWithFormat:@"%@[%@]", name, @(counter)] atIndentationLevel:indentationLevel+1]];
      counter++;
    }
  }
  else if ([className rangeOfString:@"NS"].location != NSNotFound) {
    [dumpLines addObject:[DumpLine dumpLineWithFieldName:name withFieldValue:[instance description] withIndentationLevel:indentationLevel]];
  }
  else {
    [dumpLines addObject:[DumpLine dumpLineWithFieldName:name withFieldValue:[[instance class] description] withIndentationLevel:indentationLevel]];
    [dumpLines addObjectsFromArray:[ObjectDumper dumpProperties:instance classType:[instance class] atIndentationLevel:indentationLevel+1]];
  }

  return dumpLines;
}


+ (NSString *)dump:(id)instance {
  NSArray *dumpLines = [ObjectDumper dumpRecursive:instance withName:@"DUMP" atIndentationLevel:0];
  NSMutableString *string = [NSMutableString string];
  for (DumpLine *dumpLine in dumpLines) {
    [string appendFormat:@"%@\n", dumpLine];
  }
  return string;
}

@end
