//
//  ViewController.m
//  Aspects_Brief
//
//  Created by DingYusong on 2019/3/15.
//  Copyright © 2019 DingYusong. All rights reserved.
//

#import "ViewController.h"
#import "DYSDog.h"
#import "DYSSimpleAspects.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [DYSDog dysAspect_hookSelector:@selector(specie) withOptions:DYSSimpleAspectOptionAfter usingBlock:^(){
        NSLog(@"爬行的");
    } error:nil];
    
    
    [DYSDog specie];
}

@end
