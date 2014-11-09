//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013-2014 Scott Talbot.

#import "STFloatLabelTextField.h"


static CGFloat const STFloatLabelTextFieldPlaceholderTextAlpha = .4;


static CGFloat STFloatFloor(CGFloat f);
static CGFloat STFloatCeil(CGFloat f);
static CGSize STSizeCeil(CGSize sz);
static CGPoint STRectGetMid(CGRect r);
typedef NS_ENUM(NSInteger, STRectAlignment) {
    STRectAlignmentXLeft = 0x01,
    STRectAlignmentXCenter = 0x02,
    STRectAlignmentXRight = 0x04,
    STRectAlignmentYTop = 0x10,
    STRectAlignmentYCenter = 0x20,
    STRectAlignmentYBottom = 0x40,
    STRectAlignmentOriginIntegral = 0x100,
};
static CGRect STRectAlign(CGRect r, CGSize s, STRectAlignment m);
static CGAffineTransform STAffineTransformMakeWithInitialRectAndTargetRect(CGRect rect, CGRect targetRect);


@implementation STFloatLabelTextField {
@private
    UILabel *_placeholderLabel;
    UILabel *_shrunkenPlaceholderLabel;
    BOOL _placeholderShrunken;
    UILabel *_errorLabel;
    CGSize _size;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGRect const bounds = self.bounds;

        _placeholderLabel = [[UILabel alloc] initWithFrame:bounds];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _placeholderLabel.backgroundColor = [UIColor clearColor];

        _shrunkenPlaceholderLabel = [[UILabel alloc] initWithFrame:bounds];
        _shrunkenPlaceholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _shrunkenPlaceholderLabel.backgroundColor = [UIColor clearColor];

        _errorLabel = [[UILabel alloc] initWithFrame:bounds];
        _errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.textAlignment = NSTextAlignmentRight;

        [self addSubview:_shrunkenPlaceholderLabel];
        [self addSubview:_placeholderLabel];
        [self addSubview:_errorLabel];

        [self layoutSubviews];
        [self st_setFont:self.font];
        [self st__setPlaceholderShrunken:NO animated:NO];

        _errorLabel.textColor = [UIColor colorWithRed:222./255. green:102./255. blue:102./255. alpha:1];
    }
    return self;
}

- (void)tintColorDidChange {
    UIColor * const tintColor = self.tintColor;
    [_placeholderLabel setHighlightedTextColor:tintColor];
    [_shrunkenPlaceholderLabel setHighlightedTextColor:tintColor];
}


- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self st_setFont:font];
}
- (void)st_setFont:(UIFont *)font {
    CGFloat const shrunkenRatio = 2./3.;
    UIFont * const shrunkenFont = [font fontWithSize:round(font.pointSize * shrunkenRatio)];

    [_placeholderLabel setFont:font];
    [_shrunkenPlaceholderLabel setFont:shrunkenFont];
    [_errorLabel setFont:shrunkenFont];
    [self st_layoutSubviews];
}

- (void)setTextColor:(UIColor *)color {
    [super setTextColor:color];

    UIColor * const placeholderColor = [color colorWithAlphaComponent:STFloatLabelTextFieldPlaceholderTextAlpha];

    [_placeholderLabel setTextColor:placeholderColor];
    [_shrunkenPlaceholderLabel setTextColor:placeholderColor];
}


- (void)setTitle:(NSString *)title {
    _title = title.copy;
    [self st_refreshPlaceholderText];
    [self st_layoutSubviews];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    [self st_refreshPlaceholderText];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    [super setAttributedPlaceholder:attributedPlaceholder];
    [self st_refreshPlaceholderText];
}

- (void)st_refreshPlaceholderText {
//    .attributedPlaceholder unsupported
    _placeholderLabel.text = self.placeholder;
    _shrunkenPlaceholderLabel.text = self.title ?: self.placeholder;
    [self st_layoutSubviews];
}


- (void)setError:(NSString *)error {
    _errorLabel.text = error.copy;
    [self st_layoutSubviews];
}


- (BOOL)becomeFirstResponder {
    [_placeholderLabel setHighlighted:YES];
    [_shrunkenPlaceholderLabel setHighlighted:YES];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [_placeholderLabel setHighlighted:NO];
    [_shrunkenPlaceholderLabel setHighlighted:NO];
    return [super resignFirstResponder];
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const offsetTop = STFloatFloor(height / 6);
    return CGRectOffset(bounds, 0, offsetTop);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGFloat const height = CGRectGetHeight(bounds);
    CGFloat const offsetTop = STFloatFloor(height / 6);
    return CGRectOffset(bounds, 0, offsetTop);
}

- (void)drawPlaceholderInRect:(CGRect)rect {}

- (void)layoutSubviews {
    [super layoutSubviews];

    BOOL const hasText = self.text.length > 0;

    CGRect const bounds = self.bounds;
    if (!CGSizeEqualToSize(_size, bounds.size)) {
        _size = bounds.size;
        [self st_layoutSubviews];
    }

    [self st_setPlaceholderShrunken:hasText animated:YES];
}

- (void)st_layoutSubviews {
    CGRect const bounds = self.bounds;

    UILabel * const placeholderLabel = _placeholderLabel;
    UILabel * const shrunkenPlaceholderLabel = _shrunkenPlaceholderLabel;
    UILabel * const errorLabel = _errorLabel;

    CGSize const placeholderLabelSize = STSizeCeil([placeholderLabel sizeThatFits:bounds.size]);
    CGSize const shrunkenPlaceholderLabelSize = STSizeCeil([shrunkenPlaceholderLabel sizeThatFits:bounds.size]);
    CGSize const errorLabelSize = STSizeCeil([errorLabel sizeThatFits:bounds.size]);

    CGRect const placeholderLabelRect = STRectAlign(bounds, placeholderLabelSize, STRectAlignmentXLeft|STRectAlignmentYCenter|STRectAlignmentOriginIntegral);
    CGRect const shrunkenPlaceholderLabelRect = STRectAlign(bounds, shrunkenPlaceholderLabelSize, STRectAlignmentXLeft|STRectAlignmentYTop|STRectAlignmentOriginIntegral);
    CGRect const errorLabelRect = STRectAlign(bounds, errorLabelSize, STRectAlignmentXRight|STRectAlignmentYTop|STRectAlignmentOriginIntegral);

    placeholderLabel.transform = CGAffineTransformIdentity;
    shrunkenPlaceholderLabel.transform = CGAffineTransformIdentity;
    errorLabel.transform = CGAffineTransformIdentity;

    placeholderLabel.frame = placeholderLabelRect;
    shrunkenPlaceholderLabel.frame = shrunkenPlaceholderLabelRect;
    errorLabel.frame = errorLabelRect;
}

- (void)st_setPlaceholderShrunken:(BOOL)shrunken animated:(BOOL)animated {
    if (shrunken != _placeholderShrunken) {
        [self st__setPlaceholderShrunken:shrunken animated:animated];
    }
}
- (void)st__setPlaceholderShrunken:(BOOL)shrunken animated:(BOOL)animated {
    _placeholderShrunken = shrunken;

    UILabel * const placeholderLabel = _placeholderLabel;
    UILabel * const shrunkenPlaceholderLabel = _shrunkenPlaceholderLabel;

    CGRect const placeholderLabelRect = placeholderLabel.frame;
    CGRect const shrunkenPlaceholderLabelRect = shrunkenPlaceholderLabel.frame;

    CGFloat const placeholderLabelAlpha = shrunken ? 0 : 1;
    CGAffineTransform const placeholderLabelTransform = CGAffineTransformIdentity;
    CGAffineTransform const placeholderLabelShrunkenTransform = STAffineTransformMakeWithInitialRectAndTargetRect(placeholderLabelRect, shrunkenPlaceholderLabelRect);

    CGFloat const shrunkenPlaceholderLabelAlpha = shrunken ? 1 : 0;
    CGAffineTransform const shrunkenPlaceholderLabelTransform = STAffineTransformMakeWithInitialRectAndTargetRect(shrunkenPlaceholderLabelRect, placeholderLabelRect);
    CGAffineTransform const shrunkenPlaceholderLabelShrunkenTransform = CGAffineTransformIdentity;

    void (^animations)(void) = ^{
        placeholderLabel.alpha = placeholderLabelAlpha;
        placeholderLabel.transform = shrunken ? placeholderLabelShrunkenTransform : placeholderLabelTransform;
        shrunkenPlaceholderLabel.alpha = shrunkenPlaceholderLabelAlpha;
        shrunkenPlaceholderLabel.transform = shrunken ? shrunkenPlaceholderLabelShrunkenTransform : shrunkenPlaceholderLabelTransform;
    };
    if (animated) {
        placeholderLabel.transform = shrunken ? placeholderLabelTransform : placeholderLabelShrunkenTransform;
        shrunkenPlaceholderLabel.transform = shrunken ? shrunkenPlaceholderLabelTransform : shrunkenPlaceholderLabelShrunkenTransform;
        [UIView animateWithDuration:1./8. delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:animations completion:nil];
    } else {
        animations();
    }
}

@end


static CGFloat STFloatFloor(CGFloat f) {
#if defined(CGFLOAT_IS_DOUBLE) && CGFLOAT_IS_DOUBLE
    return floor(f);
#else
    return floorf(f);
#endif
}
static CGFloat STFloatCeil(CGFloat f) {
#if defined(CGFLOAT_IS_DOUBLE) && CGFLOAT_IS_DOUBLE
    return ceil(f);
#else
    return ceilf(f);
#endif
}

static CGSize STSizeCeil(CGSize sz) {
    return (CGSize){
        .width = STFloatCeil(sz.width),
        .height = STFloatCeil(sz.height),
    };
}

static NSUInteger const STRectAlignmentXMask = 0x07;
static NSUInteger const STRectAlignmentYMask = 0x70;
static CGRect STRectAlign(CGRect rect, CGSize size, STRectAlignment alignment) {
    CGRect r = { .size = size };
    switch (alignment & STRectAlignmentXMask) {
        case STRectAlignmentXLeft: {
            r.origin.x = CGRectGetMinX(rect);
        } break;
        case STRectAlignmentXCenter: {
            r.origin.x = CGRectGetMidX(rect) - size.width / 2.;
        } break;
        case STRectAlignmentXRight: {
            r.origin.x = CGRectGetMaxX(rect) - size.width;
        } break;
    }
    switch (alignment & STRectAlignmentYMask) {
        case STRectAlignmentYTop: {
            r.origin.y = CGRectGetMinY(rect);
        } break;
        case STRectAlignmentYCenter: {
            r.origin.y = CGRectGetMidY(rect) - size.height / 2.;
        } break;
        case STRectAlignmentYBottom: {
            r.origin.y = CGRectGetMaxY(rect) - size.height;
        } break;
    }
    return r;
}

static CGPoint STRectGetMid(CGRect rect) {
    return (CGPoint){
        .x = CGRectGetMidX(rect),
        .y = CGRectGetMidY(rect),
    };
}

static CGAffineTransform STAffineTransformMakeWithInitialRectAndTargetRect(CGRect initialRect, CGRect targetRect) {
    if (CGRectIsNull(initialRect) || CGRectIsNull(targetRect)) {
        return CGAffineTransformIdentity;
    }

    CGPoint const initialRectCenter = STRectGetMid(initialRect);
    CGPoint const targetRectCenter = STRectGetMid(targetRect);
    CGVector const translation = (CGVector){
        .dx = targetRectCenter.x - initialRectCenter.x,
        .dy = targetRectCenter.y - initialRectCenter.y,
    };

    CGSize const initialRectSize = initialRect.size;
    CGSize const targetRectSize = targetRect.size;
    CGVector const scale = (CGVector){
        .dx = (initialRectSize.width > 0) ? (targetRectSize.width / initialRectSize.width) : INFINITY,
        .dy = (initialRectSize.height > 0) ? (targetRectSize.height / initialRectSize.height) : INFINITY,
    };

    return CGAffineTransformMake(scale.dx, 0, 0, scale.dy, translation.dx, translation.dy);
}
