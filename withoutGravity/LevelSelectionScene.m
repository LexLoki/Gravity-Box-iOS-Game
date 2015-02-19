//
//  LevelSelectionScene.m
//  withoutGravity
//
//  Created by Pietro Ribeiro Pepe on 2/17/15.
//  Copyright (c) 2015 Pietro Ribeiro Pepe. All rights reserved.
//

#import "LevelSelectionScene.h"
#import "GameScene.h"

@implementation LevelSelectionScene

NSMutableArray *contentArray;
NSMutableArray *status, *requisites;
int world;


-(void)didMoveToView:(SKView *)view{
    //HERE WE START LOADING STUFF
    world=0;
    status = [self loadStatus:world]; //Eventually we will get the map from mapScene
    [self setSelection];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInNode:self];
        SKSpriteNode *node = (SKSpriteNode*)[self nodeAtPoint:location];
        if(node.name!=NULL){
            int level = [node.name intValue];
            if([[status objectAtIndex:level] intValue]!=0)
                [self enterStage:level ofMap:world];
        }
        break; //gambiarra pra pegar só 1 touch
    }
}

-(void)setSelection{
    NSInteger quant=status.count, i, div=5, total=25, quantX, quantY;
    CGFloat taxax, taxay, x, y;
    CGRect gameRectangle;
    
    quantX = div; //Quantos mapas por linha (ou seja, quantas colunas)
    quantY = (quant-1)/div;  //Quantos mapas por coluna (ou seja, quantas linhas)
    
    //Sem espacamento
    /*
    taxax=0.8*self.frame.size.width/quantX;
    taxay=0.8*self.frame.size.height/quantY;
     */
    
    CGFloat espX=0.5, espY=0.5;
    //Com espacamento
    taxax=0.8*self.frame.size.width/(quantX + (quantX-1)*espX);
    taxay=0.8*self.frame.size.height/(quantY + (quantY-1)*espY);
    
    if(taxax<taxay){
        taxay=taxax;
        espY=(0.8*self.frame.size.height-taxay*quantY)/(quantY-1);
        espX*=taxax;
    }
    else{
        taxax=taxay;
        espX=(0.8*self.frame.size.width-taxax*quantX)/(quantX-1);
        espY*=taxay;
    }
    x=taxax*quantX;
    y=taxay*quantY;
    
    gameRectangle = CGRectMake(self.frame.size.width/2-x/2, self.frame.size.height/2+y/2, x, y);
    CGPoint origin = CGPointMake(self.frame.size.width*0.1+taxax/2, self.frame.size.height*0.1+taxay/2);
    
    for(i=0;i<quant;i++){
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"boxcolor"]; //A INSERIR
        //node.xScale = self.frame.size.width/5/node.size.width;
        //node.yScale = node.xScale;
        [node setSize:CGSizeMake(taxax, taxay)];
        node.name=[[ NSNumber numberWithInteger:i] stringValue];
        node.zPosition=5;
        //node.position =CGPointMake((i%div)*node.size.width+origin.x,(i/div)*node.size.height+origin.y); //INSERIR LOCAL
        node.position =CGPointMake((i%div)*(taxax+espX)+origin.x,(i/div)*(taxay+espY)+origin.y);
        //HERE ADD AND ETC
        //DEVIDE IF WE WILL HAVE A PARENT NODE TO HOLD LEVELS (PRETTY MUCH UNLIKELY)
    }
}

-(NSMutableArray*)loadStatus:(int)map{
    
    NSString *plistPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    plistPath = [plistPath stringByAppendingPathComponent:@"stagesData.plist"];
    contentArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    //</por>
    
    NSMutableArray *mapData = [contentArray objectAtIndex:map];
    NSMutableArray *stat = [[NSMutableArray alloc]initWithCapacity:[mapData count]];
    requisites = [[NSMutableArray alloc]initWithCapacity:[mapData count]];
    for (NSDictionary *stage in mapData){
        [stat addObject:[stage objectForKey:@"status"]];
    }
    return stat;
}

//[self enterStage:level ofMap:world];
-(void)enterStage:(int)stage ofMap:(int)map{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"stagesData" ofType:@"plist"];
    contentArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    NSArray *mapData = [contentArray objectAtIndex:map];
    NSDictionary *selectedStage = [mapData objectAtIndex:stage];
    NSString *filename = [selectedStage objectForKey:@"filename"];
    NSLog(@"%@", filename);
    
    GameScene *gameScene = [[GameScene alloc] initWithSize:self.view.bounds.size];
    [gameScene setLevelToLoad:filename map:map stage:stage]; //This command to set fistr level
    //[gameScene setLevelVolumeSound:masterSoundVolume music:masterMusicVolume];
    SKTransition * trans = [SKTransition fadeWithDuration:1.0];
    [self.view presentScene:gameScene transition:trans];
}

@end
