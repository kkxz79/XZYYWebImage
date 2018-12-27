//
//  XZHomeTableViewController.m
//  XZYYWebImage
//
//  Created by kkxz on 2018/12/26.
//  Copyright © 2018 kkxz. All rights reserved.
//

#import "XZHomeTableViewController.h"

@interface XZHomeTableViewController ()
@property(nonatomic,strong)NSMutableArray *titles;
@property(nonatomic,strong)NSMutableArray *classNames;
@end

@implementation XZHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titles = @[].mutableCopy;
    self.classNames = @[].mutableCopy;
    [self addCell:@"Simple WebImage" class:@"XZSimpleWebImageViewController"];
    [self addCell:@"List WebImage" class:@"XZWebImageTableViewController"];
}

-(void)addCell:(NSString*)title class:(NSString*)className {
    [self.titles addObject:title];
    [self.classNames addObject:className];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XZCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XZCell"];
    }
    cell.textLabel.text = _titles[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * className = self.classNames[indexPath.row];
    Class class = NSClassFromString(className);
    if(class){
        UIViewController *vc = class.new;
        vc.title = _titles[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
