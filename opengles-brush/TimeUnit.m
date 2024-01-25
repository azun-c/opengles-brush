//
//  TimeUnit.m
//  i-Reporter
//
//  Created by KUROSAKI Ryota on 2019/01/07.
//  Copyright © 2019 CIMTOPS CORPORATION. All rights reserved.
//

#import "TimeUnit.h"

TimeUnit TimeUnitCreate(NSString *value) {
    if ([value isEqualToString:@"Hour"]) {
        return TimeUnitHour;
    } else if ([value isEqualToString:@"Minute"]) {
        return TimeUnitMinute;
    } else if ([value isEqualToString:@"Second"]) {
        return TimeUnitSecond;
    } else if ([value isEqualToString:@"Millisecond"]) {
        return TimeUnitMillisecond;
    } else {
        return TimeUnitHour;
    }
}

NSString * TimeUnitToString(TimeUnit timeUnit) {
    switch (timeUnit) {
        case TimeUnitHour:
            return @"Hour";
        case TimeUnitMinute:
            return @"Minute";
        case TimeUnitSecond:
            return @"Second";
        case TimeUnitMillisecond:
            return @"Millisecond";
    }
}

NSInteger TimeUnitIntegerFromUnitToMillisecond(NSInteger value, TimeUnit timeUnit) {
    switch (timeUnit) {
        case TimeUnitHour:
            return value * 60 * 60 * 1000;
        case TimeUnitMinute:
            return value * 60 * 1000;
        case TimeUnitSecond:
            return value * 1000;
        case TimeUnitMillisecond:
            return value;
    }
}

NSDecimalNumber * TimeUnitDecimalNumberFromUnitToMillisecond(NSDecimalNumber *value, TimeUnit timeUnit) {
    switch (timeUnit) {
        case TimeUnitHour:
            return [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"3600000"]];
        case TimeUnitMinute:
            return [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"60000"]];
        case TimeUnitSecond:
            return [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        case TimeUnitMillisecond:
            return value;
    }
}

NSInteger TimeUnitIntegerFromMillisecondToUnit(NSInteger millisecond, TimeUnit toUnit) {
    switch (toUnit) {
        case TimeUnitHour:
            return millisecond / 1000 / 60 / 60;
        case TimeUnitMinute:
            return millisecond / 1000 / 60;
        case TimeUnitSecond:
            return millisecond / 1000;
        case TimeUnitMillisecond:
            return millisecond;
    }
}

NSDecimalNumber * TimeUnitDecimalNumberFromMillisecondToUnit(NSDecimalNumber *millisecond, TimeUnit toUnit) {
    switch (toUnit) {
        case TimeUnitHour:
            return [millisecond decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"3600000"]];
        case TimeUnitMinute:
            return [millisecond decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"60000"]];
        case TimeUnitSecond:
            return [millisecond decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        case TimeUnitMillisecond:
            return millisecond;
    }
}

