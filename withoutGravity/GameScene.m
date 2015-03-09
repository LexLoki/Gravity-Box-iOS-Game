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

float masterSoundVolume, masterMusicVolume;
bool enableGravityChange, timerStarted;
NSMutableArray *boxesArray, *boxesPosArray;
NSString *levelToLoad=@"stage001";
NSInteger actualStage, actualMap;
CGRect gameRectangle;
NSInteger boxesTotal, boxesCleared;
CFTimeInterval timeCount;
SKSpriteNode *gameNode;
NSInteger moveCount;

CGFloat barY;

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
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    [background setSize:self.frame.size];
    background.position = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
    [self addChild:background];
    
    
    CGSize size, target=CGSizeMake(0.1*self.frame.size.width, 0.1*self.frame.size.height);
    CGSize margin = CGSizeMake(0.05*self.frame.size.width, 0.05*self.frame.size.height);
    UIImage *img;
    
    //Left button definition
    img = [UIImage imageNamed:@"left"];
    size = [self setSizeForImage:img toSize:target];
    self.leftGravity = [[UIButton alloc] initWithFrame:CGRectMake(margin.width,self.frame.size.height-margin.height-size.height,size.width, size.height)];
    [self.leftGravity setBackgroundImage:img forState:UIControlStateNormal];
    [self.leftGravity addTarget:self action:@selector(gravityClockWise) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftGravity];
    //Right button definition
    img = [UIImage imageNamed:@"right"];
    size = [self setSizeForImage:img toSize:target];
    self.rightGravity = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-margin.width-size.width,self.frame.size.height-margin.width-size.height,size.width, size.height)];
    [self.rightGravity setBackgroundImage:img forState:UIControlStateNormal];
    [self.rightGravity addTarget:self action:@selector(gravityAntiClockWise) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightGravity];
    //Reset button definition
    img = [UIImage imageNamed:@"reload"];
    size = [self setSizeForImage:img toSize:target];
    self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-margin.width-size.width, margin.height, size.width, size.height)];
    [self.resetButton setBackgroundImage:img forState:UIControlStateNormal];
    [self.resetButton addTarget:self action:@selector(resetBoxes) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    self.physicsWorld.contactDelegate=self;
    [self makeScenario];
    timerStarted=false;
    enableGravityChange=true;
}

-(CGSize)setSizeForImage:(UIImage*)img toSize:(CGSize)target{
    CGFloat x = target.width/img.size.width, y = target.height/img.size.height;
    if(x>y){
        x=img.size.width*y;
        y=target.height;
    }
    else{
        y=img.size.height*x;
        x=target.width;
    }
    return CGSizeMake(x, y);
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
        //CGPoint location = [touch locationInNode:self];
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
    
    fscanf(arq,"%ld%ld",&quantX, &quantY);
    taxax=0.8*self.frame.size.width/quantX;
    taxay=0.8*self.frame.size.height/quantY;
    if(taxax<taxay)
        taxay=taxax;
    else
        taxax=taxay;
    
    x=taxax*quantX;
    y=taxay*quantY;
    
    SKTexture *bar = [SKTexture textureWithImageNamed:@"bar"];
    barY = (taxax/bar.size.width)*bar.size.height;
    
    gameRectangle = CGRectMake(self.frame.size.width/2-x/2, self.frame.size.height/2-y/2, x, y);
    
    
    //gameNode = [[SKSpriteNode alloc]initWithColor:[SKColor blueColor] size:gameRectangle.size];
    //gameNode = [[SKSpriteNode alloc]initWithColor:[SKColor blueColor] size:gameRectangle.size];
    //gameNode = [SKSpriteNode spriteNodeWithImageNamed:@"crateBack"];
    gameNode = [SKSpriteNode node];
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
    fscanf(arq, "%ld", &quant);
    for(NSInteger i=0;i<quant;i++){
        fscanf(arq, "%ld%ld%ld", &lin, &col, &total);
        for(j=0;j<total;j++){
            fscanf(arq, "%ld", &angle);
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
    SKSpriteNode *obj=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"bar"]];
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
    fscanf(arq, "%ld", &quant);
    for(NSInteger i=0;i<quant;i++){
        fscanf(arq,"%ld%ld%ld", &type, &lin, &col);
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
    SKSpriteNode *obj=[SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cubegame"]];
    obj.zPosition=5;
    //obj.xScale = 0.75*taxax/obj.size.width; //PRIMEIRO MODO
    obj.xScale = (taxax-2*barY)/obj.size.width;  //SEGUNDO MODO, JUSTAPOSTO
    obj.yScale = obj.xScale;
    //obj.position=CGPointMake(gameRectangle.origin.x+col*taxax+taxax/2, gameRectangle.origin.y-lin*taxay-taxay/2);
    //obj.position=CGPointMake(col*taxax+taxax/2, gameNode.frame.size.height-lin*taxay-taxay/2);
    obj.position=CGPointMake(col*taxax+taxax/2-gameNode.frame.size.width/2, gameNode.frame.size.height/2-lin*taxay-taxay/2);
    //obj.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:obj.size];
    obj.physicsBody=[SKPhysicsBody bodyWithTexture:obj.texture size:obj.size];
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
    fscanf(arq, "%ld", &quant);
    for(NSInteger i=0;i<quant;i++){
        fscanf(arq,"%ld%ld%ld", &type, &lin, &col);
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
    NSLog(@"lin -> %ld col -> %ld", lin, col);
    obj.position=CGPointMake(col*taxax+taxax/2-gameNode.frame.size.width/2, gameNode.frame.size.height/2-lin*taxay-taxay/2);
    obj.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:obj.size];
    obj.physicsBody.dynamic=false;
    obj.physicsBody.categoryBitMask=exitCategory;
    obj.physicsBody.collisionBitMask=0;
    [gameNode addChild:obj];
}

-(void)resetBoxes2{
    NSInteger quant = boxesArray.count;
    for(NSInteger i=0;i<quant;i++)
        [boxesArray[i] removeFromParent];
    [gameNode runAction:[SKAction rotateToAngle:0 duration:0.5f] completion:^{
        for(NSInteger i=0;i<quant;i++){
            SKSpriteNode *box = [boxesArray objectAtIndex:i];
            box.physicsBody.velocity=CGVectorMake(0,0);
            box.zRotation=0;
            box.position=[boxesPosArray[i] CGPointValue];
            [gameNode addChild:box];
        }
    }];
}

-(void)resetBoxes{
    NSInteger quant = boxesArray.count;
    for(NSInteger i=0;i<quant;i++)
        [boxesArray[i] removeFromParent];
    SKAction *effect = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1f],[SKAction rotateToAngle:0 duration:0.0f],[SKAction fadeInWithDuration:0.1f]]];
    [gameNode runAction:effect completion:^{
        for(NSInteger i=0;i<quant;i++){
            SKSpriteNode *box = [boxesArray objectAtIndex:i];
            box.physicsBody.velocity=CGVectorMake(0,0);
            box.zRotation=0;
            box.position=[boxesPosArray[i] CGPointValue];
            [gameNode addChild:box];
        }
    }];
}

-(void)setMenu{
    
}

-(void)menuBeginSelection:(NSSet*)touches{
    
}

-(void)menuMovedSelection:(NSSet*)touches{
    
}

-(void)menuEndedSelection:(NSSet*)touches{
    
}

-(void)endStage{
    //Por enquanto simplesmente 0 indisponivel, 1 disponivel, 2 passado.
    //Ao passar uma fase na qual o status nao é 2, atualizamos o status dela e o da proxima (caso nao seja a ultima)
    NSString *plistPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    plistPath = [plistPath stringByAppendingPathComponent:@"stagesData.plist"];
    NSMutableArray *contentArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    //setScore here
    NSMutableArray *mapData = [contentArray objectAtIndex:actualMap];
    //[(NSMutableDictionary*)[[contentArray objectAtIndex:actualMap] objectAtIndex:actualStage] setObject:[NSNumber numberWithInt:2] forKey:@"status"];
    if([[mapData[actualStage] objectForKey:@"status"] integerValue]!=2){ //ampliar complexidade com score
        [mapData[actualStage] setObject:[NSNumber numberWithInt:2] forKey:@"status"];
        if(actualStage!=mapData.count) //setar proxima para disponivel
            [mapData[actualStage+1] setObject:[NSNumber numberWithInt:1] forKey:@"status"];
        [contentArray writeToFile:plistPath atomically:YES];
    }
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

-(void) setLevelToLoad : (NSString *) levelFileName map : (int) cMap stage : (int) cStage{
    levelToLoad=levelFileName;
    actualStage=cStage;
    actualMap=cMap;
    
}
-(void) setLevelVolumeSound : (float) targetSound music : (float) targetMusic{
    masterSoundVolume=targetSound;
    masterMusicVolume=targetMusic;
}

-(void)willMoveFromView:(SKView *)view{
    [self removeAllChildren];
}

@end
