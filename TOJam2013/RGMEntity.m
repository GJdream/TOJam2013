//
//  RGMEntity.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-03.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMEntity.h"

NSTimeInterval invincibilityDuration = 3;

@interface RGMEntity ()

@property (nonatomic, copy, readwrite) NSString *identifier;

@end



@implementation RGMEntity {
    BOOL _isJumping;
    NSDate *_jumpDate;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _x = [aDecoder decodeIntegerForKey:@"x"];
        _y = [aDecoder decodeIntegerForKey:@"y"];
        _velocity = [aDecoder decodeCGPointForKey:@"velocity"];
        _size = [aDecoder decodeCGSizeForKey:@"size"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeInteger:self.x forKey:@"x"];
    [aCoder encodeInteger:self.y forKey:@"y"];
    [aCoder encodeCGPoint:self.velocity forKey:@"velocity"];
    [aCoder encodeCGSize:self.size forKey:@"size"];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier.length > 0);
    
    if (self = [super init]) {
        _identifier = [identifier copy];
        _x = 0;
        _y = 0;
        _velocity = CGPointZero;
        _canJump = NO;
        _size = CGSizeMake(RGMTileSize, RGMTileSize);
    }
    
    return self;
}

- (NSString *)description
{
    NSMutableString *description = [[super description] mutableCopy];
    [description appendFormat:@"frame: %@, velocity: %@", NSStringFromCGRect([self frame]), NSStringFromCGPoint(self.velocity)];
    
    return [description copy];
}

- (void)updateForDuration:(NSTimeInterval)duration
{
    const CGFloat gravity = [self gravity];
    const CGFloat maxDownwardVelocity = MAXFLOAT;
    
    CGPoint velocity = self.velocity;
    velocity.y += gravity * duration;
    velocity.y = MIN(maxDownwardVelocity, velocity.y);
    self.velocity = velocity;
    self.canJump = NO;
}

- (CGFloat)gravity
{
    return _isJumping ? 0 : 3000;
}

- (void)jump
{
    if (!self.canJump) {
        return;
    }
    
    self.velocity = CGPointMake(self.velocity.x, -500);
    self.canJump = NO;
    _isJumping = YES;
    
    const NSTimeInterval jumpDuration = 0.15f;
    [self performSelector:@selector(endJump) withObject:nil afterDelay:jumpDuration inModes:@[NSRunLoopCommonModes]];
}

- (void)endJump
{
    _isJumping = NO;
}

- (CGRect)frame
{
    return CGRectMake(self.x, self.y, self.size.width, self.size.height);
}

- (void)setInvincible:(BOOL)invincible
{
    if (_invincible == invincible) {
        return;
    }
    
    _invincible = invincible;
    [self performSelector:@selector(reset) withObject:nil afterDelay:invincibilityDuration inModes:@[NSRunLoopCommonModes]];
}

- (void)reset
{
    self.invincible = NO;
}

@end
