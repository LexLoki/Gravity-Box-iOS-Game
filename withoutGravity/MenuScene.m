//
//  MenuScene.m
//  withoutGravity
//
//  Created by Pietro Ribeiro Pepe on 3/6/15.
//  Copyright (c) 2015 Pietro Ribeiro Pepe. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"

@implementation MenuScene

SKSpriteNode *selectedNode;
UIButton *button;

-(void)didMoveToView:(SKView *)view{
    [self loadInterface];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(touches.count>1)
        return;
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInNode:self];
        selectedNode = (SKSpriteNode*)[self nodeAtPoint:location];
        if(selectedNode.name!=NULL)
            selectedNode.alpha=0.6;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(touches.count>1)
        return;
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInNode:self];
        if(selectedNode.name!=NULL)
            selectedNode.alpha=(CGRectContainsPoint(selectedNode.frame, location))?0.6:1;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(touches.count>1)
        return;
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInNode:self];
        if(selectedNode.name!=NULL){
            if(CGRectContainsPoint(selectedNode.frame, location)){
                [self doAction];
            }
            else
                selectedNode.alpha=1;
        }
    }
    selectedNode=NULL;
}

-(void)doAction{
    if([selectedNode.name isEqualToString:@"p"])
        [self goToMapScene];
    else if([selectedNode.name isEqualToString:@"s"])
        [self goToSettingsScene];
}

-(void)goToMapScene{
    GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
    SKTransition * trans = [SKTransition fadeWithDuration:1.0];
    [self.view presentScene:gameScene transition:trans];
}

-(void)goToSettingsScene{
    selectedNode.alpha=1;
}

-(void)loadInterface{
    CGFloat backWidth = 1920, backHeight = 1080.;
    CGFloat boxWidth = 380./backWidth, boxHeight = 380./backHeight, boxPosY = 289./backHeight;
    CGFloat playWidth = 160./backWidth, playHeight = 116./backHeight, playPosY = 400./backHeight;
    CGFloat settingsPosY = 234./backHeight;
    
    CGFloat width, height, scale;
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    background.zPosition=0;
    [background setSize:self.frame.size];
    background.position=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:background];
    
    SKSpriteNode *cube = [SKSpriteNode spriteNodeWithImageNamed:@"cube"];
    cube.zPosition=1;
    width = self.frame.size.width*boxWidth, height = self.frame.size.height*boxHeight;
    (width>height)?(width=height):(height=width);
    [cube setSize:CGSizeMake(width, height)];
    cube.position = CGPointMake(self.frame.size.width/2, (1-boxPosY)*self.frame.size.height);
    [self addChild:cube];
    
    SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"title"];
    [title setSize:CGSizeMake(cube.size.width*0.9, cube.size.height*0.5)];
    [cube addChild:title];
    
    SKSpriteNode *play = [SKSpriteNode spriteNodeWithImageNamed:@"play"];
    play.zPosition=1;
    width = self.frame.size.width * playWidth, height = self.frame.size.height * playHeight;
    [play setScale:height/play.texture.size.height];
    play.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*playPosY);
    [self addChild:play];
    play.name = @"p";
    
    SKSpriteNode *settings = [SKSpriteNode spriteNodeWithImageNamed:@"settings"];
    scale = self.frame.size.height/backHeight;
    settings.zPosition=1;
    [settings setScale:scale];
    settings.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*settingsPosY);
    [self addChild:settings];
    settings.name = @"s";
}

@end
