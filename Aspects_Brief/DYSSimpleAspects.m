//
//  DYSSimpleAspects.m
//  AspectsDemo
//
//  Created by 丁玉松 on 2019/3/11.
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//

#import "DYSSimpleAspects.h"
#import <objc/runtime.h>

@implementation NSObject (DYSSimpleAspects)

+ (void)dysAspect_hookSelector:(SEL)selector
                withOptions:(DYSSimpleAspectOption)options
                 usingBlock:(id)block
                      error:(NSError **)error {
    //1.保存原来的方法。
    //2.老方法的IMP指针指向新方法。
    //3.根据Option调用新方法和老方法
    
    
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
    objc_allocateClassPair(baseClass, subClassName, 0);
    
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

}

- (void)dysAspect_hookSelector:(SEL)selector
                withOptions:(DYSSimpleAspectOption)options
                 usingBlock:(id)block
                      error:(NSError **)error {
    //1.保存原来的方法。
    //2.老方法的IMP指针指向新方法。
    //3.根据Option调用新方法和老方法
    
    
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
    objc_allocateClassPair(baseClass, subClassName, 0);

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
}

// This is the swizzled forwardInvocation: method.
static void __ASPECTS_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {



}



@end
