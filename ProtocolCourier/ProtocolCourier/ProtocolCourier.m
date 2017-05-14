//
//  ProtocolCourier.m
//  ProtocolCourier
//
//  Created by GuYi on 2017/5/13.
//
//

#import "ProtocolCourier.h"
#import <objc/objc-runtime.h>

@interface ProtocolCourier ()
@property (nonatomic, strong) Protocol * protocol;
@property (nonatomic, strong) NSOrderedSet * objects;
@end

@implementation ProtocolCourier

+ (instancetype)packageForProtocol:(Protocol *)protocol withObjects:(NSArray *)objects {
    ProtocolCourier *courier = [[super alloc] initWithProtocol:protocol objects:objects];
    return courier;
}

- (instancetype)initWithProtocol:(Protocol*)protocol objects:(NSArray*)objects {
    _protocol = protocol;
    
    NSMutableArray * validObjects = [NSMutableArray array];
    
    NSAssert(objects.count > 0, @"必须添加需要转发的对象");
    
    for (id object in objects) {
        if ([self object:object conformsProtocolOrAdoptedByProtocol:protocol]) {
            [validObjects addObject:object];
        }
    }
    
    NSAssert(validObjects.count > 0, @"添加的类并没有遵守%@这个协议或者这个协议所采用的协议", NSStringFromProtocol(protocol));
    
    _objects = [NSOrderedSet orderedSetWithArray:validObjects];
    
    return self;
}

- (NSArray *)attachedObjects {
    return [self.objects array];
}

#pragma mark - forward methods
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return protocol_conformsToProtocol(self.protocol, aProtocol);
}

- (BOOL)respondsToSelector:(SEL)selector {
    BOOL responds = NO;
    BOOL isRequired = NO;
    
    struct objc_method_description methodDescription = [self methodDescriptionForSelector:selector isRequired:&isRequired];
    
    //设计初衷：如果是是 required 方法就必须通过 Courier 来响应
    if (isRequired) {
        responds = YES;
    }
    else if (methodDescription.name != NULL) {
        responds = [self checkIfAttachedObjectsRespondToSelector:selector];
    }
    
    return responds;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    
    BOOL isRequired = NO;
    
    struct objc_method_description methodDescription = [self methodDescriptionForSelector:selector isRequired:&isRequired];
    
    if (methodDescription.name == NULL) {
        [super forwardInvocation:anInvocation];
        return;
    }
    
    BOOL someoneResponded = NO;
    for (id object in self.objects) {
        if ([object respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:object];
            someoneResponded = YES;
        }
    }
    
    NSAssert(!(isRequired && !someoneResponded), @"%@方法未实现", NSStringFromSelector(selector));
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature * methodSignature;
    
    BOOL isRequired = NO;
    struct objc_method_description methodDescription = [self methodDescriptionForSelector:selector isRequired:&isRequired];
    
    if (methodDescription.name == NULL) {
        return [super methodSignatureForSelector:selector];
    }
    
    methodSignature = [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
    
    return methodSignature;
}

#pragma mark - private method

/**
 通过递归查找这个对象是否遵守了整个协议链中的至少一个协议

 @param object 当前对象
 @param protocol 遵守的协议
 @return 这个对象是否遵守了这个协议或者这个协议所继承包含的协议
 */
- (BOOL)object:(id)object conformsProtocolOrAdoptedByProtocol:(Protocol*)protocol {
    if ([object conformsToProtocol:protocol]) {
        return YES;
    }
    
    BOOL conforms = NO;
    
    unsigned int count = 0;
    Protocol * __unsafe_unretained * list = protocol_copyProtocolList(protocol, &count);
    for (NSUInteger i = 0; i < count; i++) {
        Protocol * aProtocol = list[i];
        
        // NSObject 协议因为所有类都包含了所以直接跳过
        if ([NSStringFromProtocol(aProtocol) isEqualToString:@"NSObject"]) continue;
        
        if ([self object:object conformsProtocolOrAdoptedByProtocol:aProtocol]) {
            conforms = YES;
            break;
        }
    }
    free(list);
    
    return conforms;
}


/**
 通过 SEL 递归查找当前这个方法是否是在整个协议链中，如果包含则返回方法描述

 @param selector 方法 SEL
 @param isRequired 是否是 required 方法
 @return 方法描述
 */
- (struct objc_method_description)methodDescriptionForSelector:(SEL)selector isRequired:(BOOL *)isRequired {
    struct objc_method_description method = {NULL, NULL};
    
    method = [self methodDescriptionInProtocol:self.protocol selector:selector isRequired:isRequired];
    
    if (method.name == NULL) {
        unsigned int count = 0;
        Protocol * __unsafe_unretained * list = protocol_copyProtocolList(self.protocol, &count);
        for (NSUInteger i = 0; i < count; i++) {
            Protocol * aProtocol = list[i];
            
            if ([NSStringFromProtocol(aProtocol) isEqualToString:@"NSObject"]) continue;
            
            method = [self methodDescriptionInProtocol:aProtocol selector:selector isRequired:isRequired];
            if (method.name != NULL) {
                break;
            }
        }
        free(list);
    }
    
    return method;
}


/**
 检查当前方法是否包含在这个协议中

 @param protocol 当前协议
 @param selector 当前方法
 @param isRequired 是否是 required 方法
 @return 方法描述，不包含则返回 NULL
 */
- (struct objc_method_description)methodDescriptionInProtocol:(Protocol *)protocol selector:(SEL)selector isRequired:(BOOL *)isRequired {
    struct objc_method_description method = {NULL, NULL};
    
    //返回一个指定的方法的方法描述结构给定的协议
    method = protocol_getMethodDescription(protocol, selector, YES, YES);
    if (method.name != NULL) {
        *isRequired = YES;
        return method;
    }
    
    method = protocol_getMethodDescription(protocol, selector, NO, YES);
    if (method.name != NULL) {
        *isRequired = NO;
    }
    
    return method;
}


/**
 查找所有装载的对象是否响应当前方法

 @param selector 当前方法
 @return 是否响应
 */
- (BOOL)checkIfAttachedObjectsRespondToSelector:(SEL)selector {
    for (id object in self.objects) {
        if ([object respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}

@end
