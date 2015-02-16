//
//  GameScene.m
//  withoutGravity
//
//  Created by Pietro Ribeiro Pepe on 1/20/15.
//  Copyright (c) 2015 Pietro Ribeiro Pepe. All rights reserved.
//

/*   .txt instructions:
 
 First comes the dimensions of the grid.
 Second comes the number of entries for wall placement.
    Then for each entry: 3 values, 2 are coordinates of the place, the other how many walls in that "square".
        Followed by the type of each wall in that square(0-down, 1-right, 2-up, 3-left).
 Third comes the number of entries for box placement.
    Then for each entry: 1 value, the type of the box (0-objective, 1-support).
        Followed by the coordinates of the place the box will be.
*/

#define BOX 1
#define WALL 20

#import "GameScene.h"
@import CoreMotion;

@interface GameScene()
@property (nonatomic) UIButton *leftGravity;
@property (nonatomic) UIButton *rightGravity;
@property (nonatomic) UIButton *resetButton;
@end

@implementation GameScene

static const uint32_t boxCategory = 0x1 << 1;
static const uint32_t exitCategory = 0x1 << 0;
static const uint32_t wallCategory = 0x1 << 2;

bool enableGravityChange, timerStarted;
NSMutableArray *boxesArray, *boxesPosArray;
NSString *levelToLoad=@"stage001";
CGRect gameRectangle;
NSInteger boxesTotal, boxesCleared;
CFTimeInterval timeCount;
SKSpriteNode *gameNode;
NSInteger moveCount;

-(void)didMoveToView:(SKView *)view {
    enableGravityChange=false;
    /* Setup your scene here */
    [self setButtons];
    
}

-(void)setLabel{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel.text = @"You got it";
    myLabel.fontSize = 65;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    myLabel.zPosition=10;
    [self addChild:myLabel];
}

-(void)setButtons{
    //Left button definition
    self.leftGravity = [[UIButton alloc] initWithFrame:CGRectMake(0,0.9*self.frame.size.height,0.1*self.frame.size.width, 0.1*self.frame.size.height)];
    [self.leftGravity setBackgroundImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    [self.leftGravity addTarget:self action:@selector(gravityClockWise) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftGravity];
    //Right button definition
    self.rightGravity = [[UIButton alloc] initWithFrame:CGRectMake(0.9*self.frame.size.width,0.9*self.frame.size.height,0.1*self.frame.size.width, 0.1*self.frame.size.height)];
    [self.rightGravity setBackgroundImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    [self.rightGravity addTarget:self action:@selector(gravityAntiClockWise) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightGravity];
    //Reset button definition
    self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.9*self.frame.size.width, 0, 0.1*self.frame.size.width, 0.1*self.frame.size.height)];
    [self.resetButton setBackgroundImage:[UIImage imageNamed:@"resetArrow"] forState:UIControlStateNormal];
    [self.resetButton addTarget:self action:@selector(resetBoxes) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    self.physicsWorld.contactDelegate=self;
    [self makeScenario];
    timerStarted=false;
    enableGravityChange=true;
}

-(void)gravityClockWise{
    [self changeGravity:1];
}

-(void)gravityAntiClockWise{
    [self changeGravity:-1];
}

-(void)changeGravity2:(NSInteger)direction{
    if(enableGravityChange){
        enableGravityChange=false;
        self.physicsWorld.gravity=CGVectorMake(self.physicsWorld.gravity.dy*direction, -self.physicsWorld.gravity.dx*direction);
    }
}

-(void)changeGravity:(NSInteger)direction{
    if(enableGravityChange){
        enableGravityChange=false;
        for(SKSpriteNode *box in boxesArray){
            box.physicsBody.dynamic=false;
        }
        [gameNode runAction:[SKAction rotateByAngle:direction*M_PI/2 duration:0.5f] completion:^{
            for(SKSpriteNode *box in boxesArray){
                box.physicsBody.dynamic=true;
            }
        }];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    NSLog(@"HUE");
    [self setLabel];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.xScale = 0.5;
        sprite.yScale = 0.5;
        sprite.position = location;
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}

-(void)makeScenario{
    FILE *arq;
    NSInteger quantX, quantY;
    float taxax, taxay, x, y;
    boxesTotal=boxesCleared=0;
    NSString* path = [[NSBundle mainBundle] pathForResource:levelToLoad ofType:@"txt"];
    //arq=fopen("/Users/Piupas/Desktop/JogoTeste/JogoTeste/fase1.txt","rt");
    arq=fopen([path UTF8String],"rt");
    if(arq==NULL){
        NSLog(@"ERRO");
        return;
    }
    
    fscanf(arq,"%d%d",&quantX, &quantY);
    taxax=0.8*self.frame.size.width/quantX;
    taxay=0.8*self.frame.size.height/quantY;
    if(taxax<taxay)
        taxay=taxax;
    else
        taxax=taxay;
    
    x=taxax*quantX;
    y=taxay*quantY;
    
    gameRectangle = CGRectMake(self.frame.size.width/2-x/2, self.frame.size.height/2-y/2, x, y);
    
    
    //gameNode = [[SKSpriteNode alloc]initWithColor:[SKColor blueColor] size:gameRectangle.size];
    //gameNode = [[SKSpriteNode alloc]initWithColor:[SKColor blueColor] size:gameRectangle.size];
    gameNode = [SKSpriteNode spriteNodeWithImageNamed:@"crateBack"];
    [gameNode setSize:gameRectangle.size];
    
    gameNode.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    //gameNode.position=gameRectangle.origin;
    
    //Here we load the elements of the stage - walls only until now
    [self readWalls:arq taxax:taxax taxay:taxay];
    
    //Here we load the boxes
    boxesArray = [[NSMutableArray alloc] initWithCapacity:5];
    boxesPosArray = [[NSMutableArray alloc] initWithCapacity:5];
    [self readBoxes:arq taxax:taxax taxay:taxay];
    
    //Here we load the exits
    [self readExits:arq taxax:taxax taxay:taxay];
    
    [self addChild:gameNode];
    fclose(arq);
}

-(void)readWalls:(FILE*)arq
           taxax:(float)taxax
           taxay:(float)taxay{
    NSInteger lin, col, total, j, angle, quant;
    fscanf(arq, "%d", &quant);
    for(NSInteger i=0;i<quant;i++){
        fscanf(arq, "%d%d%d", &lin, &col, &total);
        for(j=0;j<total;j++){
            fscanf(arq, "%d", &angle);
            [self placeWall:angle lin:lin col:col taxax:taxax taxay:taxay];
        }
    }
}

-(void)placeWall:(NSInteger)type
             lin:(NSInteger)lin
             col:(NSInteger)col
           taxax:(float)taxax
           taxay:(float)taxay{
    
    //CGPoint pos = CGPointMake(gameRectangle.origin.x+col*taxax+taxax/2, gameRectangle.origin.y-lin*taxay-taxay/2);
    //CGPoint pos = CGPointMake(col*taxax+taxax/2, gameNode.frame.size.height-lin*taxay-taxay/2);
    CGPoint pos = CGPointMake(col*taxax+taxax/2-gameNode.frame.size.width/2, gameNode.frame.size.height/2-lin*taxay-taxay/2);
    CGFloat angle;
    switch(type){
        case 0:{
            pos.y-=taxay/2;
            angle=0;
            break;
        }
        case 1:{
            pos.x+=taxax/2;
            angle=0.5;
            break;
        }
        case 2:{
            pos.y+=taxay/2;
            angle=0;
            break;
        }
        case 3:{
            pos.x-=taxax/2;
            angle=0.5;
            break;
        }
        default: return;
    }
    SKSpriteNode *obj=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"mirror"]];
    obj.zRotation=angle*M_PI;
    obj.zPosition=5;
    obj.xScale = taxax/obj.size.width;
    obj.yScale = obj.xScale;
    obj.position=pos;
    obj.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:obj.size];
    obj.physicsBody.dynamic=false;
    obj.physicsBody.categoryBitMask=wallCategory;
    //[self addChild:obj];
    [gameNode addChild:obj];
    
}

-(void)readBoxes:(FILE*)arq
           taxax:(float)taxax
           taxay:(float)taxay{

    NSInteger quant, lin, col, type;
    fscanf(arq, "%d", &quant);
    for(NSInteger i=0;i<quant;i++){
        fscanf(arq,"%d%d%d", &type, &lin, &col);
        [self placeBox:type lin:lin col:col taxax:taxax taxay:taxay];
    }
    
}

-(void)placeBox:(NSInteger)type
            lin:(NSInteger)lin
            col:(NSInteger)col
          taxax:(float)taxax
          taxay:(float)taxay{
    switch(type){
        case 0:{
            boxesTotal++;
            break;
        }
        case 1:{
            
            break;
        }
    }
    SKSpriteNode *obj=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"boxcolor"]];
    obj.zPosition=5;
    obj.xScale = 0.75*taxax/obj.size.width;
    obj.yScale = obj.xScale;
    //obj.position=CGPointMake(gameRectangle.origin.x+col*taxax+taxax/2, gameRectangle.origin.y-lin*taxay-taxay/2);
    //obj.position=CGPointMake(col*taxax+taxax/2, gameNode.frame.size.height-lin*taxay-taxay/2);
    obj.position=CGPointMake(col*taxax+taxax/2-gameNode.frame.size.width/2, gameNode.frame.size.height/2-lin*taxay-taxay/2);
    obj.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:obj.size];
    obj.physicsBody.mass=1000;
    obj.physicsBody.categoryBitMask=boxCategory;
    obj.physicsBody.collisionBitMask=wallCategory|boxCategory;
    obj.physicsBody.contactTestBitMask=exitCategory;
    
    [boxesArray addObject:obj];
    [boxesPosArray addObject:[NSValue valueWithCGPoint:obj.position]];
    //[self addChild:obj];
    [gameNode addChild:obj];
}

-(void)readExits:(FILE*)arq
           taxax:(float)taxax
           taxay:(float)taxay{
    
    NSInteger quant, lin, col, type;
    fscanf(arq, "%d", &quant);
    for(NSInteger i=0;i<quant;i++){
        fscanf(arq,"%d%d%d", &type, &lin, &col);
        [self placeExit:type lin:lin col:col taxax:taxax taxay:taxay];
    }
    
}

-(void)placeExit:(NSInteger)type
            lin:(NSInteger)lin
            col:(NSInteger)col
          taxax:(float)taxax
          taxay:(float)taxay{
    SKSpriteNode *obj = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(taxax,taxay)];
    obj.zPosition=3;
    NSLog(@"lin -> %d col -> %d", lin, col);
    obj.position=CGPointMake(col*taxax+taxax/2-gameNode.frame.size.width/2, gameNode.frame.size.height/2-lin*taxay-taxay/2);
    obj.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:obj.size];
    obj.physicsBody.dynamic=false;
    obj.physicsBody.categoryBitMask=exitCategory;
    obj.physicsBody.collisionBitMask=0;
    [gameNode addChild:obj];
}

-(void)resetBoxes{
    NSInteger quant = boxesArray.count;
    for(NSInteger i=0;i<quant;i++)
        [boxesArray[i] removeFromParent];
    [gameNode runAction:[SKAction rotateToAngle:0 duration:0.5f] completion:^{
        for(NSInteger i=0;i<quant;i++){
            SKSpriteNode *box = [boxesArray objectAtIndex:i];
            box.physicsBody.velocity=CGVectorMake(0,0);
            box.position=[boxesPosArray[i] CGPointValue];
            [gameNode addChild:box];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(!enableGravityChange){
        if(!timerStarted){
            timerStarted=true;
            timeCount=currentTime;
        }
        else{
            if(currentTime-timeCount>=1.0){
                enableGravityChange=true;
                timerStarted=false;
            }
        }
    }
}

@end
