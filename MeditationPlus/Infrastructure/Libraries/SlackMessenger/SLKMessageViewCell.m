//
//  SLKMessageViewCell.m
//  Messenger
//
//  Created by Ignacio Romero Z. on 11/4/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

#import "SLKMessageViewCell.h"

#define kImageSize 30.0

@implementation SLKMessageViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews
{
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.titleLabel];
    
    NSDictionary *views = @{@"imageView": self.imageView,
                            @"titleLabel": self.titleLabel,
                            };
    
    NSDictionary *metrics = @{@"imageSize": @(kImageSize)
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView(imageSize)]-5-[titleLabel(>=0)]|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[titleLabel]-5-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[imageView(imageSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.backgroundColor = [UIColor lightGrayColor];
        
        _imageView.layer.cornerRadius = kImageSize/2.0;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.shouldRasterize = YES;
        _imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (void)prepareForReuse
{
    self.titleLabel.text = nil;
}

@end
