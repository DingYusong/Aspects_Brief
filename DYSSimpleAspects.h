//
//  DYSSimpleAspects.h
//  AspectsDemo
//
//  Created by 丁玉松 on 2019/3/11.
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, DYSSimpleAspectOption) {
    DYSSimpleAspectOptionBefore,
    DYSSimpleAspectOptionInstead,
    DYSSimpleAspectOptionAfter,
};


@interface NSObject (DYSSimpleAspects)

+ (void)dysAspect_hookSelector:(SEL)selector
                withOptions:(DYSSimpleAspectOption)options
                 usingBlock:(id)block
                      error:(NSError **)error;


- (void)dysAspect_hookSelector:(SEL)selector
                withOptions:(DYSSimpleAspectOption)options
                 usingBlock:(id)block
                      error:(NSError **)error;

@end



NS_ASSUME_NONNULL_END
