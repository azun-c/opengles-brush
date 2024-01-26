//
//  FreeHandCurve.m
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/21.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import "FreeHandCurve.h"
#import "FreeDrawView.h"
#import "Const.h"

static NSString * const POINTS_COUNT_KEY = @"POINTS COUNT KEY";
static NSString * const POINTS_DATA_KEY = @"POINTS DATA KEY";

NS_ASSUME_NONNULL_BEGIN

@implementation FreeHandCurve

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    @synchronized(self) {
        [super encodeWithCoder:aCoder];
        
        [aCoder encodeInt:self.pointCount forKey:POINTS_COUNT_KEY];
        [aCoder encodeFloat:self.lineWidth forKey:LINE_WIDTH_KEY];
        [aCoder encodeObject:self.pointsData forKey:POINTS_DATA_KEY];
    }
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    _pointCount = [aDecoder decodeIntForKey:POINTS_COUNT_KEY];
    _lineWidth = [aDecoder decodeFloatForKey:LINE_WIDTH_KEY];
    _pointsData = [aDecoder decodeObjectForKey:POINTS_DATA_KEY];
    
    return self;
}

#pragma mark - NSObject
- (id)copyWithZone:(nullable NSZone *)zone {
    FreeHandCurve *copiedObject = [super copyWithZone:zone];
    copiedObject.pointCount = self.pointCount;
    copiedObject.lineWidth = self.lineWidth;
    copiedObject.pointsData = [NSData dataWithBytes:self.pointsData.bytes length:self.pointsData.length];
    return copiedObject;
}

- (void)dealloc {
}

#pragma mark - IDrawItem
- (BOOL)acceptRenderer:(FreeDrawView *)renderer asIndex:(int)index {
    BOOL succeeded = [renderer renderFreeHandCurve:self asIndex:index];
    return succeeded;
}

- (void)applyTransform:(CGAffineTransform)transform {
    @synchronized(self) {
        float *points = (float *)[self.pointsData bytes];
        for (int i = 0; i < self.pointCount; ++i) {
            CGPoint eachPoint = CGPointMake(points[2 * i], points[2 * i + 1]);
            eachPoint = CGPointApplyAffineTransform(eachPoint, transform);
            points[2 * i] = eachPoint.x;
            points[2 * i + 1] = eachPoint.y;
        }
    }
}

- (CGRect)boundingBox {
    CGFloat minX = INFINITY;
    CGFloat maxX = -INFINITY;
    CGFloat minY = INFINITY;
    CGFloat maxY = -INFINITY;
    
    float *points = (float *)[self.pointsData bytes];
    for (int i = 0; i < self.pointCount; ++i) {
        CGFloat eachX = points[2 * i];
        CGFloat eachY = points[2 * i + 1];
        if (eachX < minX) {
            minX = eachX;
        }
        if (eachX > maxX) {
            maxX = eachX;
        }
        if (eachY < minY) {
            minY = eachY;
        }
        if (eachY > maxY) {
            maxY = eachY;
        }
    }
    
    return CGRectInset(CGRectMake(minX, minY, maxX - minX, maxY - minY), -0.5 * self.lineWidth, -0.5 * self.lineWidth);
}

- (void)scaleData:(CGFloat)scale {
    @synchronized(self) {
        float *points = (float *)[self.pointsData bytes];
        for (int i = 0; i < self.pointCount; ++i) {
            points[2 * i] *= scale;
            points[2 * i + 1] *= scale;
        }
        self.lineWidth *= scale;
    }
}

#pragma mark - FreeHandCurve
- (id)initWithPoints:(int)count withData:(float *)pData {
    if (self = [super init]) {
        unsigned byteLength = count * 2 * sizeof(float);
        
        _pointCount = count;
        _pointsData = [NSData dataWithBytes:pData length:byteLength];
    }
    
    return self;
}

@end
NS_ASSUME_NONNULL_END
