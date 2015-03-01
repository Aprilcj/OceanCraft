#import "MainScene.h"

@implementation MainScene
- (void)play {
    NSLog(@"play");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
