//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STFloatLabelExampleViewController.h"

#import "STFloatLabelTextField.h"


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
