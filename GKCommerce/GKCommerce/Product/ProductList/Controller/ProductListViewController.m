//
//  ProductListViewController.m
//  goku-commerce.com
//
//  Created by 小悟空 on 14-9-3.
//  Copyright (c) 2014年 小悟空. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductDetailViewController.h"
#import "ProductListCollectionViewCell.h"
#import "SVPullToRefresh.h"
#import "Dependency.h"

@interface ProductListViewController ()

@end

@implementation ProductListViewController

- (id)initWithCatalog:(Catalog *)catalog user:(User *)anUser
{
    self = [self initWithNibName:@"ProductListView" bundle:nil];
    if (self) {
        SearchBackendModel *search = [[SearchBackendModel alloc] init];
        search.catalogID = catalog.catalogID;
        self.search = search;
        self.products = [[NSMutableArray alloc] init];
        self.user = anUser;
        self.catalog = catalog;
    }
    return self;
}

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.catalog)
        self.title = self.catalog.name;
    else
        self.navigationItem.title = @"选购";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    for (NSString *identifier in @[@"ProductListCollectionViewCell"])
        [self.collectionView registerNib:[UINib nibWithNibName:identifier
                                                        bundle:nil]
              forCellWithReuseIdentifier:identifier];

    self.service = [[Dependency shared] productService];
    self.service.delegate = self;

    [self.collectionView addPullToRefreshWithActionHandler:^{
        self.search.page = 1;
        [self.service productsWithSearchModel:self.search];

        CGPoint point = self.collectionView.contentOffset;
        point.y = 0;
        self.collectionView.contentOffset = point;
    }];
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        self.search.page += 1;
        [self.service productsWithSearchModel:self.search];
    }];
    self.collectionView.showsInfiniteScrolling = NO;
    
    [self.service productsWithSearchModel:self.search];
}

#pragma mark- ThreeStageSegmentViewDelegate
- (void)threeStageSegmentView:(ThreeStageSegmentView *)segment
             didSelectAtIndex:(NSInteger)index
{
    switch (index) {
        case 1:
            self.search.sort = @"price_asc";
            break;
        case 2:
            self.search.sort = @"price_desc";
            break;
        case 0:
        default:
            self.search.sort = @"id_desc";
            break;
    }
    [self.service productsWithSearchModel:self.search];
}

#pragma mark- UICollectionView
-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return self.products.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListCollectionViewCell *cell;
    Product *product;
    
    cell = [collectionView
            dequeueReusableCellWithReuseIdentifier:@"ProductListCollectionViewCell"
            forIndexPath:indexPath];
    product = [self.products objectAtIndex:indexPath.row];
    cell.product = product;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Product *product = [self.products objectAtIndex:indexPath.row];
    
    ProductDetailViewController *viewController;
    viewController = [[ProductDetailViewController alloc]
                      initWithProductID:product.productID
                      user:self.user];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(148, 194);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout
       insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 7, 5, 7);
}

#pragma mark- ProductServiceDelegate
- (void)productService:(id<ProductService>)aProductService
              products:(NSArray *)aProducts
           searchModel:(SearchBackendModel *)aSearchModel
                 error:(NSError *)anError
{
    
    
    BOOL more;
    more = aSearchModel.page > 1;
    
    if (more) {
        [self.collectionView.infiniteScrollingView stopAnimating];
        [self.products addObjectsFromArray:aProducts];
    } else {
        [self.collectionView.pullToRefreshView stopAnimating];
        self.products = [NSMutableArray arrayWithArray:aProducts];
    }
    
    [self.collectionView reloadData];
    self.collectionView.showsInfiniteScrolling = [aSearchModel hasMore];
}
@end