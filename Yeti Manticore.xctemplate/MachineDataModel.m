//
//  MachineDataModel.m
//
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MachineDataModel.h"

@implementation MachineDataModel

// http://www.galloway.me.uk/tutorials/singleton-classes/
+ (MachineDataModel*)sharedModel {
  static MachineDataModel *sharedModel = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedModel = [[self alloc] init];
  });
  return sharedModel;
}

+(BOOL) isDefined: (id) object {
  return object != nil && object != [NSNull null];
}

  ////////////////////
 //MACHINE MAPPINGS//
////////////////////
#pragma mark -
#pragma mark Machine Mappings

-(void)setupMapping {
  
}

  //////////////////////
 //MACHINE OPERATIONS//
//////////////////////
#pragma mark -
#pragma mark Machine Operations

@end
