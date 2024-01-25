//
//  IDrawItem.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/21.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "IDrawItem.h"

static NSString * const RED_KEY = @"RED KEY";
static NSString * const GREEN_KEY = @"GREEN KEY";
static NSString * const BLUE_KEY = @"BLUE KEY";
static NSString * const ALPHA_KEY = @"ALPHA KEY";

NS_ASSUME_NONNULL_BEGIN

@interface IDrawItem () 

@end

@implementation IDrawItem

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    @synchronized(self) {
        
    [aCoder encodeDouble:_red forKey:RED_KEY];
    [aCoder encodeDouble:_green forKey:GREEN_KEY];
    [aCoder encodeDouble:_blue forKey:BLUE_KEY];
    [aCoder encodeDouble:_alpha forKey:ALPHA_KEY];
        
    }
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _red = [aDecoder decodeDoubleForKey:RED_KEY];
        _green = [aDecoder decodeDoubleForKey:GREEN_KEY];
        _blue = [aDecoder decodeDoubleForKey:BLUE_KEY];
        _alpha = [aDecoder decodeDoubleForKey:ALPHA_KEY];
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    IDrawItem *copiedObject = [[[self class] allocWithZone:zone] init];
    copiedObject.red = self.red;
    copiedObject.green = self.green;
    copiedObject.blue = self.blue;
    copiedObject.alpha = self.alpha;
    return copiedObject;
}

#pragma mark - NSObject
- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

#pragma mark - IDrawItem
- (BOOL)acceptRenderer:(FreeDrawView *)renderer asIndex:(int)index {
    // 要オーバーライド
    assert(NO);
    return NO;
}

- (void)acceptRendererForSelection:(FreeDrawView *)renderer {
    // 要オーバーライド
    assert(NO);
}

- (void)applyTransform:(CGAffineTransform)applied {
}

- (CGRect)boundingBox {
    // 要オーバーライド
    assert(NO);
    return CGRectZero;
}

- (BOOL)isRotatable {
    return YES;
}

- (UIColor *)getColor {
    return [UIColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
}

- (void)setColor:(UIColor *)color {
    @synchronized(self) {
        [color getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
    }
}

- (nullable NSString *)textString {
    return nil;
}

- (nullable NSData *)jpegDataWithLocation {
    return nil;
}

- (void)scaleData:(CGFloat)scale {
    // 要オーバーライド
    assert(NO);
    return;
}

- (BOOL)isCorrectData {
    // 必要に応じてオーバーライド
    return YES;
}

@end
NS_ASSUME_NONNULL_END
