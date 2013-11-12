//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STFloatLabelTextField.h"


static CGFloat const STFloatLabelTextFieldPlaceholderEnlargedAlpha = .5;
static CGFloat const STFloatLabelTextFieldPlaceholderShrunkenAlpha = 1;


@implementation STFloatLabelTextField {
@private
    UILabel *_placeholderLabel;
    BOOL _placeholderShrunken;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGRect const bounds = self.bounds;

        self.clipsToBounds = NO;

        _placeholderLabel = [[UILabel alloc] initWithFrame:bounds];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _placeholderLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_placeholderLabel];

        [self st__setPlaceholderShrunken:NO animated:NO];
    }
    return self;
}

- (void)tintColorDidChange {
    UIColor * const tintColor = self.tintColor;
    [_placeholderLabel setHighlightedTextColor:tintColor];
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
//    NSAttributedString * const attributedPlaceholderText = self.attributedPlaceholder;
//    if (attributedPlaceholderText) {
//        _placeholderLabel.attributedText = attributedPlaceholderText;
//        return;
//    }
    NSString * const placeholderText = self.placeholder;
    _placeholderLabel.text = placeholderText;
}

- (BOOL)becomeFirstResponder {
    [_placeholderLabel setHighlighted:YES];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [_placeholderLabel setHighlighted:NO];
    return [super resignFirstResponder];
}

- (void)drawPlaceholderInRect:(CGRect)rect {}

- (void)layoutSubviews {
    [super layoutSubviews];

    BOOL const hasText = self.text.length > 0;
    [self st_setPlaceholderShrunken:hasText animated:YES];
}

- (void)st_setPlaceholderShrunken:(BOOL)shrunken animated:(BOOL)animated {
    if (shrunken != _placeholderShrunken) {
        [self st__setPlaceholderShrunken:shrunken animated:animated];
    }
}
- (void)st__setPlaceholderShrunken:(BOOL)shrunken animated:(BOOL)animated {
    _placeholderShrunken = shrunken;

    CGRect const bounds = self.bounds;
    CGAffineTransform const placeholderLabelTransform = [self.class st_placeholderTransformForBounds:bounds shrunken:shrunken];
    CGFloat const placeholderLabelAlpha = shrunken ? STFloatLabelTextFieldPlaceholderShrunkenAlpha : STFloatLabelTextFieldPlaceholderEnlargedAlpha;

    void (^animations)(void) = ^{
        _placeholderLabel.alpha = placeholderLabelAlpha;
        _placeholderLabel.transform = placeholderLabelTransform;
    };
    if (animated) {
        [UIView animateWithDuration:1./8. delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
    } else {
        animations();
    }
}

+ (CGAffineTransform)st_placeholderTransformForBounds:(CGRect)bounds shrunken:(BOOL)shrunken {
    CGFloat const placeholderLabelScale = .5;
    CGFloat const placeholderLabelTranslation = -(.5 - (placeholderLabelScale / 2.));
    CGFloat const placeholderLabelTranslationX = CGRectGetWidth(bounds) * placeholderLabelTranslation;
    CGFloat const placeholderLabelTranslationY = CGRectGetHeight(bounds) * placeholderLabelTranslation - 6;
    CGAffineTransform placeholderLabelTransform = CGAffineTransformIdentity;
    if (shrunken) {
        placeholderLabelTransform = CGAffineTransformMakeTranslation(placeholderLabelTranslationX, placeholderLabelTranslationY);
        placeholderLabelTransform = CGAffineTransformScale(placeholderLabelTransform, placeholderLabelScale, placeholderLabelScale);
    }
    return placeholderLabelTransform;
}

@end
