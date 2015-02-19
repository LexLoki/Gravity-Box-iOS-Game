//
//  GameScene.h
//  withoutGravity
//

//  Copyright (c) 2015 Pietro Ribeiro Pepe. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>

//Use this method to set next Level to load
-(void) setLevelToLoad : (NSString *) levelFileName map : (int) cMap stage : (int) cStage;
-(void) setLevelVolumeSound : (float) targetSound music : (float) targetMusic;

@end
