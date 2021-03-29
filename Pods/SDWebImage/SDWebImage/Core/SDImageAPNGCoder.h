/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageIOAnimatedCoder.h"
#import <Foundation/Foundation.h>

/**
 Built in coder using ImageIO that supports APNG encoding/decoding
 */
@interface SDImageAPNGCoder
    : SDImageIOAnimatedCoder <SDProgressiveImageCoder, SDAnimatedImageCoder>

@property(nonatomic, class, readonly, nonnull) SDImageAPNGCoder *sharedCoder;

@end
