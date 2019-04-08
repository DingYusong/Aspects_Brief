//
//  DYSSimpleAspects.m
//  AspectsDemo
//
//  Created by 丁玉松 on 2019/3/11.
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//

#import "DYSSimpleAspects.h"
#import <objc/runtime.h>
#import <objc/message.h>

typedef void (^AspectBlock)(void);

@interface AspectIdentifier : NSObject
+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(DYSSimpleAspectOption)options block:(AspectBlock)block error:(NSError **)error;
//- (BOOL)invokeWithInfo:(id<AspectInfo>)info;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) AspectBlock block;
@property (nonatomic, strong) NSMethodSignature *blockSignature;
@property (nonatomic, weak) id object;
@property (nonatomic, assign) DYSSimpleAspectOption options;
@end

@implementation AspectIdentifier

+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(DYSSimpleAspectOption)options block:(AspectBlock)block error:(NSError **)error{
    
    AspectIdentifier *identifier = [AspectIdentifier new];
    identifier.selector = selector;
    identifier.block = block;
    identifier.options = options;
    identifier.object = object;
    
    return identifier;
}

@end

//用一个对象保存被hook的方法和参数。
@interface AspectsContainer : NSObject
- (void)addAspect:(AspectIdentifier *)aspect withOptions:(DYSSimpleAspectOption)injectPosition;
- (BOOL)removeAspect:(id)aspect;
- (BOOL)hasAspects;
@property (atomic, copy) NSArray *beforeAspects;
@property (atomic, copy) NSArray *insteadAspects;
@property (atomic, copy) NSArray *afterAspects;
@end

@implementation AspectsContainer

- (void)addAspect:(AspectIdentifier *)aspect withOptions:(DYSSimpleAspectOption)options {
//    NSParameterAssert(aspect);
//    NSUInteger position = options&AspectPositionFilter;
    switch (options) {
        case DYSSimpleAspectOptionBefore:  self.beforeAspects  = [(self.beforeAspects ?:@[]) arrayByAddingObject:aspect]; break;
        case DYSSimpleAspectOptionInstead: self.insteadAspects = [(self.insteadAspects?:@[]) arrayByAddingObject:aspect]; break;
        case DYSSimpleAspectOptionAfter:   self.afterAspects   = [(self.afterAspects  ?:@[]) arrayByAddingObject:aspect]; break;
    }
}


@end



@implementation NSObject (DYSSimpleAspects)

+ (void)dysAspect_hookSelector:(SEL)selector
                withOptions:(DYSSimpleAspectOption)options
                 usingBlock:(id)block
                      error:(NSError **)error {
    // 1. 获得要hook方法的IMP
    IMP originSelectorImp = class_getMethodImplementation([self class], selector);
    
    // 2. 保存要hook的方法，方便调用
    NSString *originSelector = [NSStringFromSelector(selector) stringByAppendingString:@"_myAspect"];
    class_addMethod(self, NSSelectorFromString(originSelector), originSelectorImp, "v@:@");
    
    //3.将forwardInvocation指向新的imp，并将老的forwardInvocation的imp指针赋值给新的selector，实现备份。方便对hook方法的处理。
    IMP originalImplementation = class_replaceMethod(self, @selector(forwardInvocation:), (IMP)__ASPECTS_ARE_BEING__, "v@:@");
    if (originalImplementation) {
        class_addMethod(self, NSSelectorFromString(@"DYSAspectsForwardInvocationSelectorName"), originalImplementation, "v@:@");
    }
    
    //4. 待hook的selector直接指向了forwardInvocation
    class_replaceMethod(self, selector, _objc_msgForward, "v@:@");
    
    /**
     5. 通过AssociatedObject保存待hook信息。
        方便取出。key和selector相关联。
     */
    AspectIdentifier *identify = [AspectIdentifier identifierWithSelector:selector object:self options:options block:block error:nil];
    
    AspectsContainer *container = [AspectsContainer new];
    [container addAspect:identify withOptions:options];
    
    //一个方法建立一个AspectsContainer,一个block建立一个AspectIdentifier，container可以包含多个indetifier。
    objc_setAssociatedObject(self, NSSelectorFromString([@"aspect" stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]), container, OBJC_ASSOCIATION_RETAIN);
}

- (void)dysAspect_hookSelector:(SEL)selector
                withOptions:(DYSSimpleAspectOption)options
                 usingBlock:(id)block
                      error:(NSError **)error {
    //1.保存原来的方法。
    //2.老方法的IMP指针指向新方法。
    //3.根据Option调用新方法和老方法
    
    /**
     获得method的imp指针：class_getMethodImplementation
     Returns the function pointer that would be called if a
     particular message were sent to an instance of a class.
     */
    //获得 selector的imp
    
    //创建子类。本例中 创建一个DYSDog的子类DYSDog_myAspect
    NSString *className = NSStringFromClass([self class]);
//    NSString *subClassName = [className stringByAppendingString:@"_myAspect"];
//    Class subClass = objc_getClass(subClassName.UTF8String);
    const char *subClassName = [className stringByAppendingString:@"_myAspect"].UTF8String;
    
    //The Class object for the named class, or \c nil
    //*  if the class is not registered with the Objective-C runtime.
    Class subClass = objc_getClass(subClassName);

    
    
    /**
     * objc_allocateClassPair
     * Creates a new class and metaclass.
     *
     * @para superclass The class to use as the new class's superclass, or \c Nil to create a new root class.
     * @para name The string to use as the new class's name. The string will be copied.
     * @para extraBytes The number of bytes to allocate for indexed ivars at the end of
     *  the class and metaclass objects. This should usually be \c 0.
     */
    
    //获得类,成功创建子类
    Class baseClass = object_getClass(self);
    //Creates a new class and metaclass.
    //The new class, or Nil if the class could not be created (for example, the desired name is already in use).
    
    //[DYSDog specie]
    // baseClass 是一个class 执行类方法
//    NSLog(@"类方法");
//    [baseClass performSelector:@selector(specie)];
    // self 是一个object 执行对象方法
//    NSLog(@"对象方法");
//    [self performSelector:selector];
//    [self performSelector:@selector(learnRunning)];
    
    subClass = objc_allocateClassPair(baseClass, subClassName, 0);
//    NSLog(@"子类%s执行类方法",subClassName);
//    [subClass performSelector:@selector(specie)];

    
    
    IMP originSelectorImp = class_getMethodImplementation([self class], selector);
    NSString *originSelector = [NSStringFromSelector(selector) stringByAppendingString:@"_myAspect"];

    class_addMethod(subClass, NSSelectorFromString(originSelector), originSelectorImp, "v@:@");

    
    
    /**
     * class_replaceMethod
     * Replaces the implementation of a method for a given class.
     *
     * @para cls The class you want to modify.
     * @para name A selector that identifies the method whose implementation you want to replace.
     * @para imp The new implementation for the method identified by name for the class identified by cls.
     * @para types An array of characters that describe the types of the arguments to the method.
     *  Since the function must take at least two arguments—self and _cmd, the second and third characters
     *  must be “@:” (the first character is the return type).
     *
     * @ret The previous implementation of the method identified by \e name for the class identified by \e cls.
     */
    
    //将subClass的forwardInvocation指向新的imp，并将老的forwardInvocation的imp指针赋值给新的selector，实现备份。
    IMP originalImplementation = class_replaceMethod(subClass, @selector(forwardInvocation:), (IMP)__ASPECTS_ARE_BEING_CALLED__, "v@:@");
    if (originalImplementation) {
        class_addMethod(subClass, NSSelectorFromString(@"DYSAspectsForwardInvocationSelectorName"), originalImplementation, "v@:@");
    }
    
    //对象self的isa指针指向subClass。 将对应的对象isa指针指向创建的子类
    //object_setClass(id _Nullable obj, Class _Nonnull cls)
    object_setClass(self, subClass);

    
    /**
     Replaces the implementation of a method for a given class.
     class_replaceMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp,
     const char * _Nullable types)
     */
    // selector 直接指向了forwardInvocation
    class_replaceMethod(subClass, selector, _objc_msgForward, "v@:@");
    
    
    
    AspectIdentifier *identify = [AspectIdentifier identifierWithSelector:selector object:self options:options block:block error:nil];
    
    AspectsContainer *container = [AspectsContainer new];
    [container addAspect:identify withOptions:options];
    
    //一个方法建立一个AspectsContainer,一个block建立一个AspectIdentifier，container可以包含多个indetifier。
    objc_setAssociatedObject(self, NSSelectorFromString([@"aspect" stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]), container, OBJC_ASSOCIATION_RETAIN);
    
}

// This is the swizzled forwardInvocation: method.
static void __ASPECTS_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {

    NSLog(@"进入 forwardInvocation 的自定义imp");
    NSLog(@"invocation.selector:%s",invocation.selector);
    NSLog(@"invocation.target:%@",[invocation.target class]);
    /**
     2019-04-04 14:29:22.263186+0800 Aspects_Brief[77353:2416907] 对象开始---
     2019-04-04 14:29:22.263398+0800 Aspects_Brief[77353:2416907] 进入 forwardInvocation 的自定义imp
     2019-04-04 14:29:22.263501+0800 Aspects_Brief[77353:2416907] invocation.selector:learnRunning
     2019-04-04 14:29:22.263611+0800 Aspects_Brief[77353:2416907] invocation.target:DYSDog_myAspect
     2019-04-04 14:29:22.263702+0800 Aspects_Brief[77353:2416907] 对象结束---
     
     由log可见，我们执行的是[[DYSDog new] learnRunning],后面转到了 [[DYSDog_myAspect new] learnRunning]
     */
    
    NSLog(@"selector:%s",selector);
    NSLog(@"self:%s",[self class]);
    /*
     2019-04-04 14:32:46.672146+0800 Aspects_Brief[77440:2424297] selector:forwardInvocation:
     2019-04-04 14:32:46.672225+0800 Aspects_Brief[77440:2424297] self:@Eg\^B
     */
    
    NSString *conatinername = [@"aspect" stringByAppendingFormat:@"_%@", NSStringFromSelector(invocation.selector)];
    
    NSString *oricls = [NSStringFromClass([invocation.target class]) substringToIndex:6];
    
    AspectsContainer *container = objc_getAssociatedObject(self, NSSelectorFromString(conatinername));

    for (AspectIdentifier *identity in container.beforeAspects) {
        identity.block();
    }
    
    //执行原来的方法  learnRunning_myAspect
    NSString *originSelector = [NSStringFromSelector(invocation.selector) stringByAppendingString:@"_myAspect"];
    [invocation.target performSelector:NSSelectorFromString(originSelector)];

    for (AspectIdentifier *identity in container.afterAspects) {
        identity.block();
    }
}



// This is the swizzled forwardInvocation: method.
static void __ASPECTS_ARE_BEING__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {
    
//    NSLog(@"进入 forwardInvocation 的自定义imp");
//    NSLog(@"invocation.selector:%s",invocation.selector);
//    NSLog(@"invocation.target:%@",[invocation.target class]);
//    NSLog(@"selector:%s",selector);
//    NSLog(@"self:%s",[self class]);
    
    NSString *conatinername = [@"aspect" stringByAppendingFormat:@"_%@", NSStringFromSelector(invocation.selector)];
    NSString *oricls = [NSStringFromClass([invocation.target class]) substringToIndex:6];

    AspectsContainer *container = objc_getAssociatedObject(object_getClass(self), NSSelectorFromString(conatinername));
    for (AspectIdentifier *identity in container.beforeAspects) {
        identity.block();
    }
    //执行原来的方法  learnRunning_myAspect
    NSString *originSelector = [NSStringFromSelector(invocation.selector) stringByAppendingString:@"_myAspect"];
    [invocation.target performSelector:NSSelectorFromString(originSelector)];
    
    
    for (AspectIdentifier *identity in container.afterAspects) {
        identity.block();
    }
}



@end
