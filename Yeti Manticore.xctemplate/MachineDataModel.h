//
//  MachineDataModel.h
//
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MachineDataModel : NSObject

+ (MachineDataModel*)sharedModel;

+ (BOOL)isDefined: (id) object;

-(void)setupMapping;

@end
