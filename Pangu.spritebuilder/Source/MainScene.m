#import "MainScene.h"
#import "Gameplay.h"

@implementation MainScene{
    CCParticleSystem* _playButton;
}

- (void)didLoadFromCCB {
}

- (void)play {
    NSLog(@"play");
    [Gameplay loadLevel:1];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
