#import "MainScene.h"
#import "ScriptLoader.h"

@implementation MainScene{
    
}

- (void)play {
    NSLog(@"play");
    [ScriptLoader loadLevel:1];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
