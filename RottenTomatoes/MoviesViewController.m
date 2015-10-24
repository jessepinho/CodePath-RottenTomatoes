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

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSString *search;
@property (nonatomic) BOOL errorLoading;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *movieSearchBar;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;
    self.title = @"Movies";
    self.movieSearchBar.delegate = self;

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
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
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
                                                [self.movieTableView reloadData];
                                            }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.errorLoading) {
        return 1 + [self filteredMovies].count;
    } else {
        return [self filteredMovies].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowNumber = indexPath.row;
    if (self.errorLoading) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [self.movieTableView dequeueReusableCellWithIdentifier:@"errorCell"];
            return cell;
        }
        rowNumber -= 1;
    }
    MoviesTableViewCell *cell = [self.movieTableView dequeueReusableCellWithIdentifier:@"movieCell"];
    cell.titleLabel.text = [self filteredMovies][rowNumber][@"title"];
    cell.synopsisLabel.text = [self filteredMovies][rowNumber][@"synopsis"];
    NSURL *url = [NSURL URLWithString:[self filteredMovies][rowNumber][@"posters"][@"thumbnail"]];
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
    [self.movieTableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.movie = [self filteredMovies][indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUpRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMoviesFromRefreshControl) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView addSubview:self.refreshControl];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.search = searchText;
    [self.movieTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self dismissMovieSearchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.movieSearchBar.text = @"";
    self.search = @"";
    [self dismissMovieSearchBar];
    [self.movieTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [self.movieTableView reloadData];
}

- (void)dismissMovieSearchBar {
    [self.movieSearchBar endEditing:YES];
}

- (NSArray *)filteredMovies {
    if (!self.search || [self.search isEqualToString:@""]) {
        return self.movies;
    }
    NSPredicate *movieSearch = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull movie, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [movie[@"title"] rangeOfString:self.search options:NSCaseInsensitiveSearch].location != NSNotFound;
    }];
    return [self.movies filteredArrayUsingPredicate:movieSearch];
}
@end
