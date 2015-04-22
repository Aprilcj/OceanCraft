#import "MainScene.h"
#import "Gameplay.h"

@implementation MainScene{
    CCButton* _left;
    CCButton* _right;
    CCNode* _levelPic;
}

static NSInteger s_level;
static NSMutableDictionary* _gameInfo;

+ (NSDictionary*)gameInfo{
    if (!_gameInfo) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"game_info"] ofType:@"plist"];
        _gameInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    return _gameInfo;
}

+ (NSInteger)unlockedLevel{
    return [[[MainScene gameInfo] valueForKey:@"level_unlocked" ]integerValue];
}

+ (void)setUnlockedLevel:(NSInteger)level{
    [[MainScene gameInfo] setValue:[NSNumber numberWithInteger:level ]forKey:@"level_unlocked"];
}

+ (NSInteger) levelMin{
    return [[[MainScene gameInfo] valueForKey:@"level_min"] integerValue];
}

+ (NSInteger)levelMax{
    return [[[MainScene gameInfo] valueForKey:@"level_max"] integerValue];
}

+ (NSInteger)level{
    if (!s_level) {
        s_level = [MainScene unlockedLevel];
    }
    return s_level;
}

- (void)didLoadFromCCB {
    [MainScene level];
    [self updateButtons];
}

- (void)leftClick{
    s_level--;
    [self setLevelPic:s_level];
    [self updateButtons];
}

- (void)rightClick{
    s_level++;
    [self setLevelPic:s_level];
    [self updateButtons];
}

- (void)updateButtons {
    if (s_level == [MainScene levelMin]) {
        _left.enabled = false;
    }else{
        _left.enabled = true;
    }
    if (s_level == [MainScene levelMax]) {
        _right.enabled = false;
    }else{
        _right.enabled = true;
    }
}

- (void)setLevelPic:(NSInteger)level{
    [_levelPic removeAllChildren];
    NSString* fileName = nil;
    if (level > [MainScene unlockedLevel]) {
        fileName = @"ocean/lock.png";
    }else{
        fileName = [NSString stringWithFormat:@"ocean/level_%ld.png", (long)level];
    }
    CCSprite* background = [CCSprite spriteWithImageNamed:fileName];
    background.name = fileName;
    [_levelPic addChild:background];
}

- (void)play {
    if ([MainScene level] > [MainScene unlockedLevel]) {
        return;
    }
    [MainScene setUnlockedLevel:1];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:[CCTransition transitionFadeWithDuration:1]];
}
@end
