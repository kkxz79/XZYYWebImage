//
//  XZWebImageTableViewController.m
//  XZYYWebImage
//
//  Created by kkxz on 2018/12/25.
//  Copyright © 2018 kkxz. All rights reserved.
//

#import "XZWebImageTableViewController.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"

#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width

@interface XZWebImageTableCell : UITableViewCell
@property(nonatomic,strong)YYAnimatedImageView *webImageView;
@property(nonatomic,strong)CAShapeLayer *progressLayer;
@property(nonatomic,strong)UILabel *label;
@end

@implementation XZWebImageTableCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.size = CGSizeMake(kScreenWidth, kCellHeight);
    self.contentView.size = self.size;
    
    _webImageView = [YYAnimatedImageView new];
    _webImageView.size = self.size;
    _webImageView.clipsToBounds = YES;
    _webImageView.contentMode = UIViewContentModeScaleAspectFill;
    _webImageView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_webImageView];
    
    _label = [UILabel new];
    _label.size = self.size;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"Load fail,tap to reload.";
    _label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _label.hidden = YES;
    _label.userInteractionEnabled = YES;
    [self.contentView addSubview:_label];
    
    CGFloat lineHeight = 4;
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.size = CGSizeMake(_webImageView.width, lineHeight);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
    [path addLineToPoint:CGPointMake(_webImageView.width, _progressLayer.height / 2)];
    _progressLayer.lineWidth = lineHeight;
    _progressLayer.path = path.CGPath;
    _progressLayer.strokeColor = [UIColor colorWithRed:0.000 green:0.640 blue:1.000 alpha:0.720].CGColor;
    _progressLayer.lineCap = kCALineCapButt;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    [_webImageView.layer addSublayer:_progressLayer];
    
    __weak typeof (self)_self = self;
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
        [_self setImageURL:_self.webImageView.yy_imageURL];
    }];
    [_label addGestureRecognizer:g];
    
    return self;
}

- (void)setImageURL:(NSURL *)url {
    _label.hidden = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.progressLayer.hidden = YES;
    self.progressLayer.strokeEnd = 0;
    [CATransaction commit];
    
    __weak typeof (self)_self = self;
    [_webImageView yy_setImageWithURL:url
                              placeholder:nil
                              options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  if(expectedSize >0 && receivedSize >0){
                                      CGFloat progress = (CGFloat)receivedSize/expectedSize;
                                      progress = progress < 0 ? 0 :(progress >1 ? 1 : progress);
                                      if(_self.progressLayer.hidden){
                                          _self.progressLayer.hidden = NO;
                                      }
                                      _self.progressLayer.strokeEnd = progress;
                                  }
                              }
                            transform:nil
                           completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                               if(stage == YYWebImageStageFinished) {
                                   _self.progressLayer.hidden = YES;
                                   if(!image){
                                       _self.label.hidden = NO;
                                   }
                               }
                           }];
}

@end

@interface XZWebImageTableViewController () {
    NSArray *_imageLinks;
}

@end

@implementation XZWebImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Reload"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = button;
    self.view.backgroundColor = [UIColor colorWithWhite:0.217 alpha:1.000];
    
    NSArray *links = @[
                       //http jpg
                       @"http://img17.3lian.com/201612/15/a57eb07acf1a67de7ad404a965f482a9.jpg",
                       //http jpeg
                       @"http://www.17qq.com/img_qqtouxiang/48511147.jpeg",
                       //https png
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1545827647397&di=55de55ec3ed22fa3fd9ff3701dfd139a&imgtype=0&src=http%3A%2F%2Fpic.qiantucdn.com%2F58pic%2F20%2F19%2F95%2F07p58PICdvj_1024.png",
                       //http gif
                       @"http://i.imgur.com/WXJaqof.gif",
                       //https gif
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1545827510946&di=6871187cea9ffba7f3529f6bb4528c5c&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fblog%2F201412%2F04%2F20141204190821_siN45.thumb.700_0.gif",
                       // animated webp and apng
                       @"http://littlesvr.ca/apng/images/BladeRunner.png",
                       @"http://littlesvr.ca/apng/images/Contact.webp",
                       ];
    
    _imageLinks = links;
    [self.tableView reloadData];
    [self scrollViewDidScroll:self.tableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = nil;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)reload {
    [[YYImageCache sharedCache].memoryCache removeAllObjects];
    [[YYImageCache sharedCache].diskCache removeAllObjectsWithBlock:^{}];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

#pragma mark - Table view data source
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _imageLinks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZWebImageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZWebImageTableCell"];
    if(!cell){
        cell = [[XZWebImageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XZWebImageTableCell"];
    }
    [cell setImageURL:[NSURL URLWithString:_imageLinks[indexPath.row % _imageLinks.count]]];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat viewHeight = scrollView.height + scrollView.contentInset.top;
    for (XZWebImageTableCell *cell in [self.tableView visibleCells]) {
        CGFloat y = cell.centerY - scrollView.contentOffset.y;
        CGFloat p = y - viewHeight / 2;
        CGFloat scale = cos(p / viewHeight*0.8)*0.95;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            cell.webImageView.transform = CGAffineTransformMakeScale(scale, scale);
        } completion:NULL];
    }
}


@end
