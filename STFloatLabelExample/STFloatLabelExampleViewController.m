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

    _textField = [[STFloatLabelTextField alloc] initWithFrame:(CGRect){ .origin = { .x = 10, .y = 30 }, .size = { .width = 100, .height = 31 } }];
    _textField.placeholder = @"Placeholder";
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;

    [view addSubview:_textField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
