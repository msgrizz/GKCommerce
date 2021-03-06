//
//  GKCartServiceImpl.h
//  GKCommerce
//
//  Created by 小悟空 on 1/31/15.
//  Copyright (c) 2015 GKCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKCartService.h"

@interface GKCartServiceImpl : NSObject <GKCartService>

- (RACSignal *)fetchCartWithUser:(GKUser *)user;
- (RACSignal *)addItem:(CartItem *)item;
- (RACSignal *)addItemWithProduct:(Product *)product cart:(Cart *)aCart;
- (RACSignal *)updateItem:(CartItem *)item oldQuantity:(NSInteger)anOldQuantity;
- (RACSignal *)removeItem:(CartItem *)item;
- (RACSignal *)removeItems:(NSArray *)items;
@end
