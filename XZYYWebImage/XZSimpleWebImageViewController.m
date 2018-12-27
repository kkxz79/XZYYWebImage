//
//  XZSimpleWebImageViewController.m
//  XZYYWebImage
//
//  Created by kkxz on 2018/12/26.
//  Copyright © 2018 kkxz. All rights reserved.
//

#import "XZSimpleWebImageViewController.h"
#import "UIView+YYAdd.h"
#import <YYWebImage/YYWebImage.h>

@interface XZSimpleWebImageViewController ()<UIActionSheetDelegate> {
    UIImageView *_imageView;
}
@end

@implementation XZSimpleWebImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"action" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    self.navigationItem.rightBarButtonItem = barButton;
   
    _imageView = [YYAnimatedImageView new];
    _imageView.size = CGSizeMake(350, 300);
    _imageView.backgroundColor = [UIColor colorWithWhite:0.790 alpha:1.000];
    _imageView.centerX = self.view.width / 2;
    _imageView.top = 64 + 10;
     [self.view addSubview:_imageView];
    
    
}

-(void)rightButtonAction {
    [[[UIActionSheet alloc]
      initWithTitle:@"图片操作"
      delegate:self
      cancelButtonTitle:@"Cancel"
      destructiveButtonTitle:nil
      otherButtonTitles:@"local",@"internet",@"gradual animation",@"gradual plus animation",@"deal pic",@"clean cache",nil]
     showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SEL selectors[] = {
        @selector(localPic),
        @selector(internetPic),
        @selector(gradualAnimation),
        @selector(gradualPlusAnimation),
        @selector(dealPic),
        @selector(clearCache)
    };
    
    if (buttonIndex < sizeof(selectors) / sizeof(SEL)) {
        void(*imp)(id, SEL) = (typeof(imp))[self methodForSelector:selectors[buttonIndex]];
        imp(self, selectors[buttonIndex]);
    }
}

#pragma mark - private methods
//加载本地图片
-(void)localPic {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"niconiconi@2x.gif" ofType:@""];
    _imageView.yy_imageURL = [NSURL fileURLWithPath:path];
}

//加载网络图片
-(void)internetPic {
    _imageView.yy_imageURL = [NSURL URLWithString:@"http://img17.3lian.com/201612/15/a57eb07acf1a67de7ad404a965f482a9.jpg"];
}

//渐进式下载，边下载边显示
-(void)gradualAnimation {
    NSURL *url = [NSURL URLWithString:@"http://uploads.5068.com/allimg/171123/1-1G123163023.jpg"];
    [_imageView yy_setImageWithURL:url options:YYWebImageOptionProgressive];
}

//渐进式加载，增加模糊效果和渐变动画
-(void)gradualPlusAnimation {
    NSURL *url = [NSURL URLWithString:@"http://00.minipic.eastday.com/20170403/20170403000037_9903446a0c36db9d9b0a8d508897469f_9.jpeg"];
    [_imageView yy_setImageWithURL:url options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
}

//加载、处理图片
-(void)dealPic {
    NSURL *url = [NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/2017-12-26/5a41ea773a1a2.jpg"];
    [_imageView yy_setImageWithURL:url
                      placeholder:nil
                          options:YYWebImageOptionSetImageWithFadeAnimation
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            CGFloat progress = (float)receivedSize / expectedSize;
                             NSLog(@"--progress--：%lf",progress);
                         }
                        transform:^UIImage *(UIImage *image, NSURL *url) {
                            image = [image yy_imageByResizeToSize:CGSizeMake(400, 400) contentMode:UIViewContentModeCenter];
                            return [image yy_imageByRoundCornerRadius:2];
                        }
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           if (from == YYWebImageFromDiskCache) {
                               NSLog(@"load from disk cache");
                           }
                       }];
}

//图片换缓存
-(void)clearCache {
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    //清空缓存
    [cache.memoryCache removeAllObjects];
//    [cache.diskCache removeAllObjects];
    
    //清空磁盘缓存，带进度回调
    [cache.diskCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
        //progress
        NSLog(@"清理进度：%lf",(double)removedCount/totalCount);
    } endBlock:^(BOOL error) {
        //end
        NSLog(@"磁盘缓存清理完成!");
    }];
}

@end
