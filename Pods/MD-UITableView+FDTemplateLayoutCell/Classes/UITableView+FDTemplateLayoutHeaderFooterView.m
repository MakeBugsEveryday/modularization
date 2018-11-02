//
//  UITableView+FDTemplateLayoutHeaderFooter.m
//  FDTemplateLayoutCell
//
//  Created by 梁宪松 on 2018/10/23.
//

#import "UITableView+FDTemplateLayoutHeaderFooterView.h"
#import <objc/runtime.h>

@implementation UITableView (FDTemplateLayoutHeaderFooterView)

- (id <NSCopying>)fd_headerFooterViewCacheKeyorSection:(NSInteger)section isHeader:(BOOL)isHeader{
    

    return [NSString stringWithFormat:@"%@_%ld_%ld", NSStringFromSelector(_cmd), (long)section, (long)isHeader];
}

- (CGFloat)fd_systemFittingHeightForConfiguratedHeaderFooterView:(UITableViewHeaderFooterView *)headerFooterView {
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);

    CGRect headerFooterBounds = headerFooterView.bounds;
    headerFooterBounds.size.width = contentViewWidth;
    headerFooterView.bounds = headerFooterBounds;
    
    // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
    // This is the same height calculation passes used in iOS8 self-sizing cell's implementation.
    //
    // 1. Try "- systemLayoutSizeFittingSize:" first. (skip this step if 'fd_enforceFrameLayout' set to YES.)
    // 2. Warning once if step 1 still returns 0 when using AutoLayout
    // 3. Try "- sizeThatFits:" if step 1 returns 0
    // 4. Use a valid height or default row height (44) if not exist one
    CGFloat fittingHeight = 0;

    if (!headerFooterView.fd_enforceFrameLayout && contentViewWidth > 0) {
        // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
        // of growing horizontally, in a flow-layout manner.
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:headerFooterView.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
        
        // [bug fix] after iOS 10.3, Auto Layout engine will add an additional 0 width constraint onto cell's content view, to avoid that, we add constraints to content view's left, right, top and bottom.
        static BOOL isSystemVersionEqualOrGreaterThan10_2 = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThan10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThan10_2) {
            // To avoid confilicts, make width constraint softer than required (1000)
            widthFenceConstraint.priority = UILayoutPriorityRequired - 1;
            
            // Build edge constraints
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:headerFooterView.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:headerFooterView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:headerFooterView.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:headerFooterView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:headerFooterView.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerFooterView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:headerFooterView.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerFooterView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [headerFooterView addConstraints:edgeConstraints];
        }
        
        [headerFooterView.contentView addConstraint:widthFenceConstraint];
        
        // Auto layout engine does its math
        fittingHeight = [headerFooterView.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // Clean-ups
        [headerFooterView.contentView removeConstraint:widthFenceConstraint];
        if (isSystemVersionEqualOrGreaterThan10_2) {
            [headerFooterView removeConstraints:edgeConstraints];
        }
        
        [self fd_debugLog:[NSString stringWithFormat:@"calculate using system fitting size (AutoLayout) - %@", @(fittingHeight)]];
    }
    
    if (fittingHeight == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (headerFooterView.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[FDTemplateLayoutHeaderFooterView] Warning once only: Cannot get a proper headerFooterView height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in headerFooterView, making it into 'self-sizing' headerFooterView.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        fittingHeight = [headerFooterView sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
        
        [self fd_debugLog:[NSString stringWithFormat:@"calculate using sizeThatFits - %@", @(fittingHeight)]];
    }
    
    return fittingHeight;
}

- (__kindof UITableViewHeaderFooterView *)fd_templateHeaderFooterViewForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewHeaderFooterView *> *templateHeaderFooterViews = objc_getAssociatedObject(self, _cmd);
    if (!templateHeaderFooterViews) {
        templateHeaderFooterViews = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateHeaderFooterViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewHeaderFooterView *templateHeaderFooterView = templateHeaderFooterViews[identifier];
    
    if (!templateHeaderFooterView) {
        templateHeaderFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        NSAssert(templateHeaderFooterView != nil, @"HeaderFooterView must be registered to table view for identifier - %@", identifier);
        templateHeaderFooterView.fd_isTemplateLayoutHeaderFooter = YES;
        templateHeaderFooterView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateHeaderFooterViews[identifier] = templateHeaderFooterView;
        [self fd_debugLog:[NSString stringWithFormat:@"layout header footer view created - %@", identifier]];
    }
    
    return templateHeaderFooterView;
}

- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id))configuration {
    UITableViewHeaderFooterView *templateHeaderFooterView = [self fd_templateHeaderFooterViewForReuseIdentifier:identifier];
    
    // Manually calls to ensure consistent behavior with actual headerFooter
    [templateHeaderFooterView prepareForReuse];

    // Customize and provide content for our template headerFooter.
    if (configuration) {
        configuration(templateHeaderFooterView);
    }

    return [self fd_systemFittingHeightForConfiguratedHeaderFooterView:templateHeaderFooterView];
}

- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier cacheBySection:(NSInteger)section isHeader:(BOOL)isHeader configuration:(void (^)(id headerFooterView))configuration {
    
    if (!identifier && section < 0) {
        return 0;
    }
    
    // Hit Cache
    return [self fd_heightForHeaderFooterViewWithIdentifier:identifier cacheByKey:[NSString stringWithFormat:@"%@", [self fd_headerFooterViewCacheKeyorSection:section isHeader:isHeader]] configuration:configuration];
}

- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id headerFooterView))configuration {
    
    if (!identifier || !key) {
        return 0;
    }
    
    // Hit cache
    if ([self.fd_keyedHeightCache existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.fd_keyedHeightCache heightForKey:key];
        [self fd_debugLog:[NSString stringWithFormat:@"hit cache by key[%@] - %@", key, @(cachedHeight)]];
        return cachedHeight;
    }

    CGFloat height = [self fd_heightForHeaderFooterViewWithIdentifier:identifier configuration:configuration];
    [self.fd_keyedHeightCache cacheHeight:height byKey:key];
    [self fd_debugLog:[NSString stringWithFormat:@"cached by key[%@] - %@", key, @(height)]];
    
    return height;
}

@end


@implementation UITableViewHeaderFooterView (FDTemplateLayoutHeaderFooterView)

- (BOOL)fd_isTemplateLayoutHeaderFooter {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_isTemplateLayoutHeaderFooter:(BOOL)isTemplateLayoutHeaderFooter {
    objc_setAssociatedObject(self, @selector(fd_isTemplateLayoutHeaderFooter), @(isTemplateLayoutHeaderFooter), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)fd_enforceFrameLayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_enforceFrameLayout:(BOOL)enforceFrameLayout {
    objc_setAssociatedObject(self, @selector(fd_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}

@end


