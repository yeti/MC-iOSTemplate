//
//  DataModel.m
//
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

// http://www.galloway.me.uk/tutorials/singleton-classes/
+ (DataModel*)sharedModel {
  static DataModel *sharedModel = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedModel = [[self alloc] init];
  });
  return sharedModel;
}



  ///////////////////
 //CUSTOM MAPPINGS//
///////////////////
#pragma mark -
#pragma mark Custom Mappings

- (void) setupMapping {
  
  [super setupMapping]; //this will get us the machine mappings
  
  //put custom mappings in here
  
}


  /////////////////////
 //CUSTOM OPERATIONS//
/////////////////////
#pragma mark -
#pragma mark Custom Operations



@end
