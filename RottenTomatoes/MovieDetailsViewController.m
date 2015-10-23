//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Jesse Pinho on 10/20/15.
//  Copyright © 2015 Jesse Pinho. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *synopsisLabelContainer;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[self getTitle]];
    [self setUpPosterImage];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    [self.synopsisLabel sizeToFit];
    self.synopsisLabelContainer.contentSize = CGSizeMake(self.synopsisLabel.bounds.size.width, self.synopsisLabel.bounds.size.height);
}

- (NSString *)getTitle {
    return [NSString stringWithFormat:@"%@ (%@)", self.movie[@"title"], self.movie[@"year"]];
}

- (void)setUpPosterImage {
    [self.posterImageView setImageWithURL:[self getLowResPosterImageURL]];
    [self.posterImageView setImageWithURL:[self getHighResPosterImageURL]];
}

- (NSURL *)getLowResPosterImageURL {
    NSString *thumbnailPosterURL = self.movie[@"posters"][@"thumbnail"];
    return [NSURL URLWithString:thumbnailPosterURL];
}

- (NSURL *)getHighResPosterImageURL {
    NSString *originalPosterURL = self.movie[@"posters"][@"original"];
    NSRange range = [originalPosterURL rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *highResPosterURL = [originalPosterURL stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    return [NSURL URLWithString:highResPosterURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
