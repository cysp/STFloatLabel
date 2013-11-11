//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STFloatLabelTextField.h"


@implementation STFloatLabelTextField {
@private
    UILabel *_shrunkenPlaceholderLabel;
    BOOL _shrunkenPlaceholderVisible;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGRect const bounds = self.bounds;

        _shrunkenPlaceholderLabel = [[UILabel alloc] initWithFrame:bounds];
        _shrunkenPlaceholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _shrunkenPlaceholderLabel.textColor = [UIColor colorWithWhite:.7 alpha:1];
        _shrunkenPlaceholderLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_shrunkenPlaceholderLabel];

        _shrunkenPlaceholderLabel.alpha = 0;
    }
    return self;
}

- (void)tintColorDidChange {
    UIColor * const tintColor = self.tintColor;
    [_shrunkenPlaceholderLabel setHighlightedTextColor:tintColor];
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
//        _shrunkenPlaceholderLabel.attributedText = attributedPlaceholderText;
//        return;
//    }
    NSString * const placeholderText = self.placeholder;
    _shrunkenPlaceholderLabel.text = placeholderText;
}

- (BOOL)becomeFirstResponder {
    [_shrunkenPlaceholderLabel setHighlighted:YES];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [_shrunkenPlaceholderLabel setHighlighted:NO];
    return [super resignFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect const bounds = self.bounds;

    CGFloat const shrunkenPlaceholderLabelScale = 3./8.;
    CGFloat const shrunkenPlaceholderLabelTranslation = -(.5 - (shrunkenPlaceholderLabelScale / 2.));
    CGFloat const shrunkenPlaceholderLabelTranslationX = CGRectGetWidth(bounds) * shrunkenPlaceholderLabelTranslation;
    CGFloat const shrunkenPlaceholderLabelTranslationY = CGRectGetHeight(bounds) * shrunkenPlaceholderLabelTranslation;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(shrunkenPlaceholderLabelTranslationX, shrunkenPlaceholderLabelTranslationY);
    transform = CGAffineTransformScale(transform, shrunkenPlaceholderLabelScale, shrunkenPlaceholderLabelScale);
    _shrunkenPlaceholderLabel.transform = transform;

    BOOL const hasText = self.text.length > 0;
    [self st_setShrunkenPlaceholderVisible:hasText animated:YES];
}

- (void)st_setShrunkenPlaceholderVisible:(BOOL)visible animated:(BOOL)animated {
    if (visible != _shrunkenPlaceholderVisible) {
        _shrunkenPlaceholderVisible = visible;

        void (^animations)(void) = ^{
            _shrunkenPlaceholderLabel.alpha = visible ? 1 : 0;
        };
        if (animated) {
            [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
        } else {
            animations();
        }
    }
}

@end
