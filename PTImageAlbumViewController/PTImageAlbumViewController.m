//
//  PTImageAlbumViewController.m
//  AlbumDemo
//
//  Created by Ali Servet Donmez on 16.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTImageAlbumViewController.h"

#import "PTImageAlbumView.h"

@interface PTImageAlbumViewController () <NIPhotoAlbumScrollViewDataSource, NIPhotoScrubberViewDataSource>

- (UIImage *)loadThumbnailImageAtIndex:(NSInteger)index;

@end

@implementation PTImageAlbumViewController

@synthesize imageAlbumView = _imageAlbumView;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _imageAlbumView = [[PTImageAlbumView alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageAlbumView.imageAlbumDataSource = self;
    
    // Internal
    self.photoAlbumView.dataSource = self;
    self.photoScrubberView.dataSource = self;
    
    // Set the default loading image
    self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                        NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];

    [self.imageAlbumView reloadData];
    [self.photoAlbumView reloadData];

    // Load all thumbnails
    for (NSInteger i = 0; i < [self.imageAlbumView numberOfImages]; i++) {
        [self loadThumbnailImageAtIndex:i];
    }
    [self.photoScrubberView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.imageAlbumView = nil;
}

#pragma mark - Private

- (UIImage *)loadThumbnailImageAtIndex:(NSInteger)index
{
    NSString *photoIndexKey = [NSString stringWithFormat:@"%d", index];
    
    UIImage *image = [self.highQualityImageCache objectWithName:photoIndexKey];
    if (image == nil) {
        [self requestImageFromSource:[self.imageAlbumView thumbnailSourceForImageAtIndex:index]
                           photoSize:NIPhotoScrollViewPhotoSizeThumbnail
                          photoIndex:index];
    }
    
    return image;
}

#pragma mark - NIPagingScrollViewDataSource

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView
{
    return [self.imageAlbumView numberOfImages];
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex
{
    // TODO enhance by replacing it with a captioned photo view
    return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}

#pragma mark - NIPhotoAlbumScrollViewDataSource

- (UIImage *)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex:(NSInteger)photoIndex
                        photoSize:(NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading:(BOOL *)isLoading
          originalPhotoDimensions:(CGSize *)originalPhotoDimensions
{
    // Let the photo album view know how large the photo will be once it's fully loaded.
    *originalPhotoDimensions = [self.imageAlbumView originalSizeForImageAtIndex:photoIndex];
    
    NSString *photoIndexKey = [NSString stringWithFormat:@"%d", photoIndex];
    
    UIImage *image = [self.highQualityImageCache objectWithName:photoIndexKey];
    if (image) {
        *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
    }
    else {
        [self requestImageFromSource:[self.imageAlbumView originalSourceForImageAtIndex:photoIndex]
                           photoSize:NIPhotoScrollViewPhotoSizeOriginal
                          photoIndex:photoIndex];
        *isLoading = YES;

        // Try to return the thumbnail image if we can.
        image = [self.thumbnailImageCache objectWithName:photoIndexKey];
        if (image) {
            *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;
        }
        else {
            // Load the thumbnail as well.
            [self requestImageFromSource:[self.imageAlbumView thumbnailSourceForImageAtIndex:photoIndex]
                               photoSize:NIPhotoScrollViewPhotoSizeThumbnail
                              photoIndex:photoIndex];
        }
    }
    
    return image;
}

- (void)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView stopLoadingPhotoAtIndex:(NSInteger)photoIndex
{
    for (NIOperation *op in self.queue.operations) {
        if (op.tag == photoIndex) {
            [op cancel];
            
            [self didCancelRequestWithPhotoSize:NIPhotoScrollViewPhotoSizeOriginal
                                     photoIndex:photoIndex];
        }
    }
}

#pragma mark - NIPhotoScrubberViewDataSource

- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView
{
    return [self.imageAlbumView numberOfImages];
}

- (UIImage *)photoScrubberView:(NIPhotoScrubberView *)photoScrubberView thumbnailAtIndex:(NSInteger)thumbnailIndex
{
    return [self loadThumbnailImageAtIndex:thumbnailIndex];
}

#pragma mark - PTImageAlbumViewDataSource

- (NSInteger)numberOfImagesInAlbumView:(PTImageAlbumView *)imageAlbumView
{
    NSAssert(NO, @"missing required method implementation 'numberOfItemsInImageAlbumView:'");
    return -1;
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForImageAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'imageAlbumView:sourceForImageAtIndex:'");
    return nil;
}

- (CGSize)imageAlbumView:(PTImageAlbumView *)imageAlbumView sizeForImageAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'imageAlbumView:sizeForImageAtIndex:'");
    return CGSizeZero;
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'imageAlbumView:sourceForThumbnailImageAtIndex:'");
    return nil;
}

@end
