#import "MainScene.h"
#import "Gameplay.h"
@implementation MainScene{
    CCButton* _left;
    CCButton* _right;
}

- (void)didLoadFromCCB {
}

- (void)leftClick{
    
}

- (void)rightClick{
    
}

- (void)play {
    NSLog(@"play");
    [Gameplay loadLevel:1];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
