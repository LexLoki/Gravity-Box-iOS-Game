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
