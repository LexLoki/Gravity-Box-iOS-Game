//
//  GameScene.m
//  withoutGravity
//
//  Created by Pietro Ribeiro Pepe on 1/20/15.
//  Copyright (c) 2015 Pietro Ribeiro Pepe. All rights reserved.
//

#define BOX 1
#define WALL 20 

#import "GameScene.h"

@interface GameScene()
@property (nonatomic) UIButton *leftGravity;
@property (nonatomic) UIButton *rightGravity;
@end

@implementation GameScene
bool enableGravityChange;
NSMutableArray *boxesArray;
NSString *levelToLoad=@"stage001";
CGRect gameRectangle;

-(void)didMoveToView:(SKView *)view {
    enableGravityChange=false;
    /* Setup your scene here */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 65;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    //[self addChild:myLabel];
    [self setButtons];
     
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
}

-(void)gravityClockWise{
    [self changeGravity:1];
}

-(void)gravityAntiClockWise{
    [self changeGravity:-1];
}

-(void)changeGravity:(NSInteger)direction{
    self.physicsWorld.gravity=CGVectorMake(self.physicsWorld.gravity.dy*direction, -self.physicsWorld.gravity.dx*direction);
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

-(void)makeScenario:(char*)filename{
    FILE *arq;
    NSInteger quantX, quantY;
    float taxax, taxay, x, y;
    boxesArray = [[NSMutableArray alloc] initWithCapacity:10];
    NSString* path = [[NSBundle mainBundle] pathForResource:levelToLoad ofType:@"txt"];
    //arq=fopen("/Users/Piupas/Desktop/JogoTeste/JogoTeste/fase1.txt","rt");
    arq=fopen([path UTF8String],"rt");
    if(arq==NULL){
        NSLog(@"ERRO");
        return;
    }
    
    NSInteger i,j,leitor;
    fscanf(arq,"%d%d",&quantX, &quantY);
    taxax=0.8*self.frame.size.width/quantX;
    taxay=0.8*self.frame.size.height/quantY;
    if(taxax<taxay)
        taxay=taxax;
    else
        taxax=taxay;
    
    x=taxax*quantX;
    y=taxay*quantY;
    
    gameRectangle = CGRectMake(self.frame.size.width/2-x/2, self.frame.size.height/2+y/2, x, y);
    
    //Here we load the elements of the stage - walls only until now
    for(i=0;i<quantY;i++)
        for(j=0;j<quantX;j++){
            if(fscanf(arq,"%d",&leitor)==0)
                break;
            if(leitor!=0)
                [self place:leitor pos1:i pos2:j scalex:taxax scaley:taxay];
        }
    fclose(arq);
}

-(void)readWalls:(FILE*)arq
           quant:(NSInteger)quant
           taxax:(float)taxax
           taxay:(float)taxay{
    NSInteger lin, col, total, j, angle;
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
    CGFloat posx = gameRectangle.origin.x, posy;
    switch(type){
        case 0:{
            break;
        }
        case 1:{
            break;
        }
        case 2:{
            break;
        }
        case 3:{
            break;
        }
        default: return;
    }
}

-(void)place:(NSInteger)num pos1:(NSInteger)i pos2:(NSInteger)j scalex:(float)taxax scaley:(float)taxay{
    NSString *name;
    float angle = 0;
    CGFloat physicsScale=1.0;
    SKSpriteNode *obj;
    CGFloat zPos = 3;
    uint32_t bitmask;
    switch (num){
            /* ** ADICIONAR MAIS ** */
        default:
            return;
    }
    obj = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:name]];
    
    [self adjustNodeToSize:CGSizeMake(taxax, taxay) node:obj angle:angle bitmask:bitmask];
    obj.position = CGPointMake(gameRectangle.origin.x+j*taxax+taxax/2, gameRectangle.origin.y-i*taxay-taxay/2); //(40,540) is the top border location
    if(bitmask==mirrorCategory)
        obj.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(obj.size.width/physicsScale, obj.size.height/10)];
    else
        obj.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(obj.size.width/physicsScale, obj.size.height/physicsScale)];
    obj.zRotation = angle*M_PI/4;
    obj.physicsBody.dynamic=false;
    
    obj.physicsBody.categoryBitMask=bitmask;
    //obj.physicsBody.collisionBitMask=0;
    obj.physicsBody.contactTestBitMask=ballCategory;
    obj.physicsBody.friction = 0.0f;
    
    [self addChild:obj];
    obj.zPosition=zPos;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
