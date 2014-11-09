//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STFloatLabelExampleViewController.h"

#import "STFloatLabelTextField.h"


@interface STFirstResponderResigningView : UIView
@end
@implementation STFirstResponderResigningView
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UITapGestureRecognizer * const tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}
- (void)tapRecognized:(UITapGestureRecognizer *)recognizer {
    [self endEditing:NO];
}
@end


@interface STFloatLabelExampleViewController () <UITextFieldDelegate>
@end

@implementation STFloatLabelExampleViewController {
@private
    STFloatLabelTextField *_textField;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void)loadView {
    CGRect const applicationFrame = [UIScreen mainScreen].applicationFrame;
    self.view = [[STFirstResponderResigningView alloc] initWithFrame:applicationFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView * const view = self.view;
    CGRect const bounds = view.bounds;

    CGRect const textFieldRect = (CGRect){
        .origin = {
            .x = 10,
            .y = 100,
        },
        .size = {
            .width = CGRectGetWidth(bounds) - 10 * 2,
            .height = 41,
        },
    };
    _textField = [[STFloatLabelTextField alloc] initWithFrame:textFieldRect];
    _textField.title = @"email";
    _textField.placeholder = @"user@example.org";
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;

    [view addSubview:_textField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    u_int32_t const r = arc4random_uniform(10);
    bool const error = r > 4;
    bool const longerror = r > 7;
    if (longerror) {
        _textField.error = @"a really extraordinarily long error message";
    } else if (error) {
        _textField.error = @"some error message";
    } else {
        _textField.error = nil;
    }
}

@end
