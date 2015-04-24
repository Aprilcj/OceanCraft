#import "MainScene.h"
#import "Gameplay.h"

@implementation MainScene{
    CCButton* _left;
    CCButton* _right;
    CCNode* _levelPic;
    CCLabelTTF* _levelName;
    CCNode* _lock;
}

static NSInteger s_level;
static NSMutableDictionary* _gameInfo;
static NSArray* s_levelPictures;
static NSArray* s_levelNames;
static NSArray* s_levelRewards;

+ (void)initStatic{
    if (!_gameInfo) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"game_info"] ofType:@"plist"];
        _gameInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        s_level = [MainScene unlockedLevel];
        s_levelPictures = @[@"ocean/octopus_3.png", @"ocean/fish_5.png", @"ocean/fish_1.png", @"ocean/sea_nail_5.png", @"ocean/turtle_1.png", @"ocean/shark_1.png", @"ocean/score_icon.png"];
        s_levelNames = @[@"Dark Lord", @"Speed Warrior", @"Toxin Friend", @"Ocean Singer", @"Turtle Rock", @"King of Sea", @"Infinity"];
        s_levelRewards=@[@""];
    }
}

+ (void)writeInfoFile{
    if (!_gameInfo) {
        return;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"game_info"] ofType:@"plist"];
    [_gameInfo writeToFile:filePath atomically:YES];
}

+ (NSInteger)unlockedLevel{
    return [[_gameInfo valueForKey:@"level_unlocked" ]integerValue];
}

+ (void)setUnlockedLevel:(NSInteger)level{
    if (level >= s_levelPictures.count) {
        return;
    }
    if (level > [self unlockedLevel]) {
        [_gameInfo setValue:[NSNumber numberWithInteger:level ]forKey:@"level_unlocked"];
        [self writeInfoFile];
    }
}

+ (NSInteger)level{
    return s_level;
}

- (void)onEnter{
    [super onEnter];
    [MainScene initStatic];
    s_level = [MainScene unlockedLevel];
    [self setLevelInfo:s_level];
    [self updateButtons];
}

- (void)leftClick{
    [[OALSimpleAudio sharedInstance] playEffect:@"select.wav"];
    s_level--;
    [self setLevelInfo:s_level];
    [self updateButtons];
}

- (void)rightClick{
    [[OALSimpleAudio sharedInstance] playEffect:@"select.wav"];
    s_level++;
    [self setLevelInfo:s_level];
    [self updateButtons];
}

- (void)updateButtons {
    if (s_level == 0) {
        _left.enabled = false;
    }else{
        _left.enabled = true;
    }
    if (s_level == [s_levelPictures count] - 1) {
        _right.enabled = false;
    }else{
        _right.enabled = true;
    }
}

- (void)setLevelInfo:(NSInteger)level{
    [_levelPic removeAllChildren];
    [_lock removeAllChildren];
    
    LOG_VAR(s_level, @"%d");
    NSString* fileName = nil;
    if (level > [MainScene unlockedLevel]) {
        fileName = @"ocean/lock.png";
        CCSprite* background = [CCSprite spriteWithImageNamed:fileName];
        background.name = fileName;
        [_lock addChild:background];
    }else{
        fileName = [s_levelPictures objectAtIndex:level];
        CCSprite* background = [CCSprite spriteWithImageNamed:fileName];
        background.name = fileName;
        [_levelPic addChild:background];
    }
    
    _levelName.string = [s_levelNames objectAtIndex:level];
}

- (void)play {
    if ([MainScene level] > [MainScene unlockedLevel]) {
        return;
    }
    [[OALSimpleAudio sharedInstance] playEffect:@"ok.wav"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:[CCTransition transitionFadeWithDuration:1]];
}
@end
