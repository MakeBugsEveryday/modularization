//
//  UITableView+FDTemplateLayoutHeaderFooter.h
//  FDTemplateLayoutCell
//
//  Created by 梁宪松 on 2018/10/23.
//

#import <UIKit/UIKit.h>
#import "UITableView+FDKeyedHeightCache.h"
#import "UITableView+FDIndexPathHeightCache.h"
#import "UITableView+FDTemplateLayoutCellDebug.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (FDTemplateLayoutHeaderFooterView)

/// Returns header or footer view's height that registered in table view with reuse identifier.
///
/// Use it after calling "-[UITableView registerNib/Class:forHeaderFooterViewReuseIdentifier]",
/// same with "-fd_heightForCellWithIdentifier:configuration:", it will call "-sizeThatFits:" for
/// subclass of UITableViewHeaderFooterView which is not using Auto Layout.
///
- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id headerFooterView))configuration;


/// Returns header or footer view's height that registered in table view with reuse identifier.
///
/// Use it after calling "-[UITableView registerNib/Class:forHeaderFooterViewReuseIdentifier]",
/// same with "-fd_heightForCellWithIdentifier:configuration:", it will call "-sizeThatFits:" for
/// subclass of UITableViewHeaderFooterView which is not using Auto Layout.
///
- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier cacheBySection:(NSInteger)section isHeader:(BOOL)isHeader configuration:(void (^)(id headerFooterView))configuration;


/// This method caches height by your model entity's identifier.
/// If your model's changed, call "-invalidateHeightForKey:(id <NSCopying>)key" to
/// invalidate cache and re-calculate, it's much cheaper and effective than "cacheByIndexPath".
///
/// @param key model entity's identifier whose data configures a cell.
///
- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id headerFooterView))configuration;

@end


@interface UITableViewHeaderFooterView (FDTemplateLayoutHeaderFooterView)

/// Indicate this is a template layout cell for calculation only.
/// You may need this when there are non-UI side effects when configure a cell.
/// Like:
///   - (void)configureCell:(FooCell *)cell atIndexPath:(NSIndexPath *)indexPath {
///       cell.entity = [self entityAtIndexPath:indexPath];
///       if (!cell.fd_isTemplateLayoutCell) {
///           [self notifySomething]; // non-UI side effects
///       }
///   }
///
@property (nonatomic, assign) BOOL fd_isTemplateLayoutHeaderFooter;

/// Enable to enforce this template layout cell to use "frame layout" rather than "auto layout",
/// and will ask cell's height by calling "-sizeThatFits:", so you must override this method.
/// Use this property only when you want to manually control this template layout cell's height
/// calculation mode, default to NO.
///
@property (nonatomic, assign) BOOL fd_enforceFrameLayout;

@end

NS_ASSUME_NONNULL_END
