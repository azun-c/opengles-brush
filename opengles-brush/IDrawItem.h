//
//  IDrawItem.h
//  i-Reporter
//
//  Created by 高津 洋一 on 12/11/21.
//  Copyright (c) 2012 CIMTOPS CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FreeDrawView;

NS_ASSUME_NONNULL_BEGIN

// Rendererに対するAcceptor
@interface IDrawItem : NSObject<NSCoding, NSCopying>
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;

- (BOOL)acceptRenderer:(FreeDrawView *)renderer asIndex:(int)index; // 抽象メソッド
- (void)acceptRendererForSelection:(FreeDrawView *)renderer; // 抽象メソッド
- (void)applyTransform:(CGAffineTransform)transform;
- (CGRect)boundingBox;
- (BOOL)isRotatable;
- (UIColor *)getColor;
- (void)setColor:(UIColor *)color;
- (nullable NSString *)textString;
- (nullable NSData *)jpegDataWithLocation;
- (void)scaleData:(CGFloat)scale;

- (BOOL)isCorrectData;// データ検証用

@end
NS_ASSUME_NONNULL_END
