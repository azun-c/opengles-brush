//
//  TimeUnit.h
//  i-Reporter
//
//  Created by KUROSAKI Ryota on 2019/01/07.
//  Copyright © 2019 CIMTOPS CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

// フォーマット入力時の時間入力、時刻計算の数値単位
typedef NS_ENUM(NSInteger, TimeUnit) {
    TimeUnitHour,  // 時間単位
    TimeUnitMinute,// 分単位
    TimeUnitSecond,// 秒単位
    TimeUnitMillisecond, // ミリ秒単位
};

TimeUnit TimeUnitCreate(NSString *value);
NSString * TimeUnitToString(TimeUnit timeUnit);
NSInteger TimeUnitIntegerFromUnitToMillisecond(NSInteger value, TimeUnit timeUnit);
NSDecimalNumber * TimeUnitDecimalNumberFromUnitToMillisecond(NSDecimalNumber *value, TimeUnit timeUnit);
NSInteger TimeUnitIntegerFromMillisecondToUnit(NSInteger millisecond, TimeUnit toUnit);
NSDecimalNumber * TimeUnitDecimalNumberFromMillisecondToUnit(NSDecimalNumber *millisecond, TimeUnit toUnit);

