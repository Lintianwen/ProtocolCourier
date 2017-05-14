//
//  ProtocolCourier.h
//  ProtocolCourier
//
//  Created by GuYi on 2017/5/13.
//
//

#import <Foundation/Foundation.h>

#define CreateProtocolCourier(__protocol__, ...) ((ProtocolCourier<__protocol__>*)[ProtocolCourier packageForProtocol:@protocol(__protocol__) withObjects:((NSArray *)[NSArray arrayWithObjects:__VA_ARGS__,nil])])

@interface ProtocolCourier : NSProxy
@property (nonatomic,strong, readonly) Protocol *protocol;
@property (nonatomic,strong, readonly) NSArray *attachedObjects;

+ (instancetype)packageForProtocol:(Protocol*)protocol withObjects:(NSArray*)objects;

@end
