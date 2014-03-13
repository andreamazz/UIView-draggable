//
//  FPViewController.m
//  UIViewDraggableDemo
//
//  Created by Andrea on 13/03/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "FPViewController.h"

#import "UIView+draggable.h"

@interface FPViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *draggableViews;

@end

@implementation FPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.draggableViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
		[obj enableDragging];
		[obj.layer setCornerRadius:4];
	}];
}

- (IBAction)actionSwitch:(UISwitch*)sender
{
	[self.draggableViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
		[obj setDraggable:sender.isOn];
	}];
}

@end
