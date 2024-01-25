//
//  TimeCalculateType.m
//  i-Reporter
//
//  Created by KUROSAKI Ryota on 2019/01/07.
//  Copyright © 2019 CIMTOPS CORPORATION. All rights reserved.
//

#import "TimeCalculateType.h"

TimeCalculateType TimeCalculateTypeCreate(NSString *value) {
    if ([value isEqualToString:@"0"]) {
        return TimeCalculateTypeV1;
    } else if ([value isEqualToString:@"1"]) {
        return TimeCalculateTypeV2;
    } else {
        return TimeCalculateTypeV1;
    }
}

NSString * TimeCalculateTypeToString(TimeCalculateType type) {
    switch (type) {
        case TimeCalculateTypeV1:
            return @"0";
        case TimeCalculateTypeV2:
            return @"1";
    }
}
