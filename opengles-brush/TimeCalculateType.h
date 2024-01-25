//
//  TimeCalculateType.h
//  i-Reporter
//
//  Created by KUROSAKI Ryota on 2019/01/07.
//  Copyright © 2019 CIMTOPS CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TimeCalculateType) {
    TimeCalculateTypeV1 = 0,
    TimeCalculateTypeV2 = 1,
};

TimeCalculateType TimeCalculateTypeCreate(NSString *value);
NSString * TimeCalculateTypeToString(TimeCalculateType type);
