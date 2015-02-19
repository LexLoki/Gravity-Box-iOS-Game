//
//  LevelSelectionScene.m
//  withoutGravity
//
//  Created by Pietro Ribeiro Pepe on 2/17/15.
//  Copyright (c) 2015 Pietro Ribeiro Pepe. All rights reserved.
//

#import "LevelSelectionScene.h"

@implementation LevelSelectionScene

NSMutableArray *contentArray;
NSMutableArray *status, *requisites;


-(void)didMoveToView:(SKView *)view{
    //HERE WE START LOADING STUFF
    status = [self loadStatus:0]; //Eventually we will get the map from mapScene
    
}

-(void)setSelection{
    NSInteger quant=status.count, i, div=5;
    CGPoint origin = CGPointMake(self.frame.size.width*0.1, self.frame.size.height*0.1);
    for(i=0;i<quant;i++){
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"INSERT"]; //A INSERIR
        node.xScale = self.frame.size.width/5/node.size.width;
        node.yScale = node.xScale;
        node.position =CGPointMake((i%div)*node.size.width+origin.x,(i/div)*node.size.height+origin.y); //INSERIR LOCAL
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

@end
