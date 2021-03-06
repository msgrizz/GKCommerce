//
//  CartStoreNameTableViewCell.m
//  GKCommerce
//
//  Created by 小悟空 on 12/3/14.
//  Copyright (c) 2014 GKCommerce. All rights reserved.
//

#import "CartStoreNameTableViewCell.h"

@interface CartStoreNameTableViewCell()

@property (strong, nonatomic) SeparatorOption *bottomBorder;
@end

@implementation CartStoreNameTableViewCell
{
    BOOL skipUpdateSelect;
}

- (void)awakeFromNib {
    skipUpdateSelect = NO;
    @weakify(self)
    [RACObserve(self, model) subscribeNext:^(id x) {
        if (nil == x)
            self.editButton.hidden = YES;
    }];
    
    [RACObserve(self, list.selected) subscribeNext:^(NSMutableArray *selected) {
        @strongify(self)
        if (skipUpdateSelect)
            return;
        
        BOOL didSelectAllItems = selected.count == self.list.items.count;
        if (self.select.on != didSelectAllItems)
            self.select.on = didSelectAllItems;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bind
{
}

- (void)unbind
{
    
}

- (void)toggleButton:(GKToggleButton *)aToggleButton didSwitch:(BOOL)onOrOff
{
    skipUpdateSelect = YES;
    CartItemList *list = self.list;
    [list selectAllItems:onOrOff];
    skipUpdateSelect = NO;
}

- (IBAction)didTapEdit:(id)sender
{
    self.model.editing = !self.model.editing;
    NSString *editTitle = self.model.editing ? @"完成" : @"编辑";
    [self.editButton setTitle:editTitle forState:UIControlStateNormal];
    SEL selector = @selector(cartStoreNameTableViewCell:didTapEdit:);
    if ([self.delegate respondsToSelector:selector])
        [self.delegate cartStoreNameTableViewCell:self didTapEdit:sender];
}

@end
