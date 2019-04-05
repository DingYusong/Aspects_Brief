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
    
    
//    [DYSDog dysAspect_hookSelector:@selector(specie) withOptions:DYSSimpleAspectOptionAfter usingBlock:^(){
//        NSLog(@"爬行的");
//    } error:nil];
//
//    NSLog(@"类开始---");
//    [DYSDog specie];
//    NSLog(@"类结束---");
    
    DYSDog *dog = [DYSDog new];

//    [dog dysAspect_hookSelector:@selector(learnRunning) withOptions:DYSSimpleAspectOptionAfter usingBlock:^(){
//        NSLog(@"AspectOptionAfter：参加奥运会");
//    } error:nil];

    
    [DYSDog dysAspect_hookSelector:@selector(learnRunning) withOptions:DYSSimpleAspectOptionBefore usingBlock:^(){
        NSLog(@"AspectOptionBefore：先学会走");
    } error:nil];
    
    NSLog(@"对象开始---");
    [dog learnRunning];
    NSLog(@"对象结束---");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DYSDog *dog = [DYSDog new];
    [dog learnRunning];

}


@end
