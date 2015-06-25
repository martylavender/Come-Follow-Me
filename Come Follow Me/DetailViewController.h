//
//  DetailViewController.h
//  Come Follow Me
//
//  Created by Marty Lavender on 6/25/15.
//  Copyright (c) 2015 Marty Lavender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Drive;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) Drive *drive;

@end

