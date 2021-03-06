//
//  RGMMenuViewController.m
//  TOJam2013
//
//  Created by Ryder Mackay on 2013-05-04.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMMenuViewController.h"
#import "RGMMainViewController.h"
#import <GameKit/GameKit.h>
#import "RGMMultiplayerGame.h"

static NSString * const kSingleplayerIdentifier = @"single";
static NSString * const kMultiplayerIdentifier = @"multi";

@interface RGMMenuViewController () <GKMatchmakerViewControllerDelegate>

- (IBAction)multiplayer:(id)sender;

@end



@implementation RGMMenuViewController {
    GKMatch *_match;
    __weak GKMatchmakerViewController *_matchmakerViewController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RGMMainViewController *controller = segue.destinationViewController;
    NSParameterAssert([controller isKindOfClass:[RGMMainViewController class]]);
    
    RGMGame *game;
    
    NSString *mapName = @"Map";
    
    if ([segue.identifier isEqualToString:kMultiplayerIdentifier]) {
        game = [[RGMMultiplayerGame alloc] initWithMapName:mapName match:_match];
        _match = nil;
    } else {
        game = [[RGMGame alloc] initWithMapName:mapName];
    }
    
    controller.game = game;
}

- (void)presentMatchmakerViewController:(GKMatchmakerViewController *)controller
{
    void (^action)() = ^{
        controller.matchmakerDelegate = self;
        _matchmakerViewController = controller;
        [self presentViewController:controller animated:YES completion:nil];
    };
    
    if (_matchmakerViewController) {
        [_matchmakerViewController dismissViewControllerAnimated:YES completion:action];
    } else {
        action();
    }
}


- (IBAction)multiplayer:(id)sender
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.defaultNumberOfPlayers = request.minPlayers;
    request.maxPlayers = 4;
    
    GKMatchmakerViewController *controller = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    controller.matchmakerDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - GKMatchmakerViewControllerDelegate

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self rgm_presentError:error];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    _match = match;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self performSegueWithIdentifier:kMultiplayerIdentifier sender:nil];
                             }];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
