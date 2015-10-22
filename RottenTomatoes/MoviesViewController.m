//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Jesse Pinho on 10/20/15.
//  Copyright © 2015 Jesse Pinho. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import <KVNProgress/KVNProgress.h>

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (nonatomic) BOOL errorLoading;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.title = @"Movies";
    [self setUpRefreshControl];
    [self fetchMoviesForFirstTime];
}

- (void)fetchMoviesForFirstTime {
    [KVNProgress show];
    [self fetchMoviesWithCompletion:^void() {
        [KVNProgress dismiss];
    }];
}

- (void)fetchMoviesWithCompletion:(void (^)())completionBlock {
    self.errorLoading = NO;

    NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    // Use ephemeral configuration to disable caching, so that we can demonstrate features related to making actual requests.
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                completionBlock();
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    self.movies = responseDictionary[@"movies"];
                                                } else {
                                                    self.errorLoading = YES;
                                                }
                                                [self.tableView reloadData];
                                            }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.errorLoading) {
        return 1 + self.movies.count;
    } else {
        return self.movies.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowNumber = indexPath.row;
    if (self.errorLoading) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"errorCell"];
            return cell;
        }
        rowNumber -= 1;
    }
    MoviesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    cell.titleLabel.text = self.movies[rowNumber][@"title"];
    cell.synopsisLabel.text = self.movies[rowNumber][@"synopsis"];
    NSURL *url = [NSURL URLWithString:self.movies[rowNumber][@"posters"][@"thumbnail"]];
    [cell.posterImageView setImageWithURL:url];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.errorLoading && indexPath.row == 0) {
        return 50;
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUpRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMoviesFromRefreshControl) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)fetchMoviesFromRefreshControl {
    [self fetchMoviesWithCompletion:^void() {
        [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
