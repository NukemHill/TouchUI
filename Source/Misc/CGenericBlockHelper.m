//
//  CGenericBlockHelper.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/18/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY 2011 JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of 2011 Jonathan Wight.

#import "CGenericBlockHelper.h"

#import <objc/runtime.h>

static void *kGenericBlockHelper;

@interface CGenericBlockHelper ()
@property (readwrite, nonatomic, retain) NSMutableDictionary *handlerForSelectors;
@end

@implementation CGenericBlockHelper

@synthesize handler;

@synthesize handlerForSelectors;

+ (CGenericBlockHelper *)genericBlockHelperForObject:(id)inObject selector:(SEL)inSelector
    {
    CGenericBlockHelper *theHelper = [self genericBlockHelperForObject:inObject ofClass:[inObject class]];
    Class theClass = [self class];
    if (class_respondsToSelector(theClass, inSelector) == NO)
        {
        void (^theIMPBlock)(CGenericBlockHelper * _self) = ^(CGenericBlockHelper * _self) {
            if (_self.handler != NULL)
                {
                _self.handler();
                }
            };
        IMP theIMP = imp_implementationWithBlock((__bridge void *)theIMPBlock);
        BOOL theResult = class_addMethod(theClass, inSelector, theIMP, "v:@");
        NSAssert(theResult == YES, @"Could not add method");
        }
    return(theHelper);
    }

+ (CGenericBlockHelper *)genericBlockHelperForObject:(id)inObject ofClass:(Class)inClass
    {
    CGenericBlockHelper *theHelper = objc_getAssociatedObject(inObject, &kGenericBlockHelper);
    if (theHelper == NULL)
        {
//        NSString *theSubclassName = [NSString stringWithFormat:@"C%@_GenericBlockHelper", NSStringFromClass([inObject class])];
//        Class theHelperClass = NSClassFromString(theSubclassName);
//        if (theHelperClass == NULL)
//            {
//            Class mySubclass = objc_allocateClassPair([NSObject class], "MySubclass", 0);
//            
//            theHelperClass = objc_allocateClassPair([CGenericBlockHelper class], [theSubclassName UTF8String], 0);
//            NSParameterAssert(theHelperClass);
//            
//            objc_registerClassPair(theHelperClass);
//            }

        Class theHelperClass = self;
        theHelper = [[theHelperClass alloc] init];
        objc_setAssociatedObject(inObject, &kGenericBlockHelper, theHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    return(theHelper);
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        handlerForSelectors = [[NSMutableDictionary alloc] init];
        }
    return self;
    }

- (void)addIMPBlock:(id)inIMPBlock forSelector:(SEL)inSelector types:(const char *)inTypes;
    {
    if (class_respondsToSelector([self class], inSelector) == YES)
        {
        return;
        }
    
    IMP theIMP = imp_implementationWithBlock((__bridge void *)inIMPBlock);
    BOOL theResult = class_addMethod([self class], inSelector, theIMP, inTypes);
    NSAssert(theResult == YES, @"Could not add method");
    }

- (void)addIMPBlock:(id)inIMPBlock forSelector:(SEL)inSelector andProtocol:(Protocol *)inProtocol
    {
    if (class_conformsToProtocol([self class], inProtocol) == NO)
        {
        class_addProtocol([self class], inProtocol);
        }
        
    struct objc_method_description theMethodDescription = protocol_getMethodDescription(inProtocol, inSelector, NO, YES);
    if (theMethodDescription.types == NO)
        {
        theMethodDescription = protocol_getMethodDescription(inProtocol, inSelector, YES, YES);
        NSParameterAssert(theMethodDescription.types);
        }
        
    [self addIMPBlock:inIMPBlock forSelector:inSelector types:theMethodDescription.types];
    }

- (void)addHandler:(void (^)(void))inHandler forSelector:(SEL)inSelector
    {
    [self.handlerForSelectors setObject:[inHandler copy] forKey:NSStringFromSelector(inSelector)];
    
    void (^theIMPBlock)(CGenericBlockHelper * _self) = ^(CGenericBlockHelper * _self) {
        void (^theHandler)(void) = [_self.handlerForSelectors objectForKey:NSStringFromSelector(inSelector)];
        if (theHandler)
            {
            theHandler();
            }
        };

    [self addIMPBlock:theIMPBlock forSelector:inSelector types:"v:@"];
    }

@end

