//
//  MapView.m
//  AXing
//
//  Created by lixy on 15/11/3.
//  Copyright © 2015年 lixy. All rights reserved.
//

#import "MapView.h"

@interface AStarPoint : NSObject

@property (nonatomic) CGPoint point;
@property (nonatomic) int direction;//1 2 3 4 上 左 下 右
@property (nonatomic) AStarPoint *prePoint;//前一个点

@end

@implementation AStarPoint

- (NSString *)description
{
    return [[NSValue valueWithCGPoint:_point] description];
}

@end

@interface MapView ()

@property (nonatomic, strong) NSMutableArray *openList;
@property (nonatomic, strong) NSMutableArray *closeList;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;

@property (nonatomic, strong) AStarPoint *curP;

@end

@implementation MapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _openList = [NSMutableArray array];
        _closeList = [NSMutableArray array];
        
        //0代表地面 1代表墙面 2 代表小猫 3 代表骨头
        int map[7][7] = {
            {0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0},
            {0,1,1,1,1,0,0},
            {0,2,0,0,1,0,0},
            {0,1,1,1,1,3,0},
            {0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0}};
        
        for (int i=0; i<7; i++) {
            for (int j=0; j<7; j++) {
                _map[i][j] = map[i][j];
                if (_map[i][j]==2) {
                    _startPoint = CGPointMake(i, j);
                }
                if (_map[i][j]==3) {
                    _endPoint = CGPointMake(i, j);
                }
            }
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] set];
    [[UIBezierPath bezierPathWithRect:rect] fill];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat everyWidth = width/7.0;
    CGFloat everyHeight = height/7.0;
    
    for (int i=0; i<7; i++) {
        for (int j=0; j<7; j++) {
            if (_map[i][j] == 1) {
                [[UIColor grayColor] set];
                
                [[UIBezierPath bezierPathWithRect:CGRectMake(everyWidth*j, everyHeight*i, everyWidth, everyHeight)] fill];
            }
            
            if (_map[i][j] == 2) {
                [[UIColor redColor] set];
                
                [[UIBezierPath bezierPathWithRect:CGRectMake(everyWidth*j, everyHeight*i, everyWidth, everyHeight)] fill];
            }
            
            if (_map[i][j] == 3) {
                [[UIColor blueColor] set];
                
                [[UIBezierPath bezierPathWithRect:CGRectMake(everyWidth*j, everyHeight*i, everyWidth, everyHeight)] fill];
            }
        }
    }
    
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    for (int i=0; i<8; i++) {
        [bp moveToPoint:CGPointMake(0, everyHeight*i)];
        [bp addLineToPoint:CGPointMake(width, everyHeight*i)];
        
        [bp moveToPoint:CGPointMake(everyWidth*i, 0)];
        [bp addLineToPoint:CGPointMake(everyWidth*i, height)];
    }
    
    [bp setLineWidth:.5];
    [[UIColor blackColor] set];
    [bp stroke];
    
    AStarPoint *firstAP = self.closeList.firstObject;
    CGPoint firstP = firstAP.point;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(firstP.y*everyWidth+everyWidth/2.0, firstP.x*everyHeight+everyHeight/2.0)];
    
    for (AStarPoint *p in self.closeList) {
        
        CGPoint tem = CGPointMake(p.point.y*everyWidth+everyWidth/2.0, p.point.x*everyHeight+everyHeight/2.0);
        [path addLineToPoint:tem];
    }
    
    [path stroke];

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.openList removeAllObjects];
    [self.closeList removeAllObjects];
    
    CGPoint e = self.endPoint;
    CGPoint p = self.startPoint;
    
    AStarPoint *start = [[AStarPoint alloc] init];
    start.point = p;
    [self.closeList addObject:start];
    
    _curP = start;
    
    //如果当前点不是目的地
    while (!CGPointEqualToPoint(_curP.point, e)) {
        
        p = _curP.point;
        
        //当前点的左侧
        if (p.x>0 && ![self hasPoint:CGPointMake(p.x-1, p.y)]) {
            AStarPoint *point = [[AStarPoint alloc] init];
            point.point = CGPointMake(p.x-1, p.y);
            point.direction = 2;
            point.prePoint = _curP;
            [self.openList addObject:point];
        }
        
        //当前点的右侧
        if (p.x<6 && ![self hasPoint:CGPointMake(p.x+1, p.y)]) {
            AStarPoint *point = [[AStarPoint alloc] init];
            point.point = CGPointMake(p.x+1, p.y);
            point.direction = 4;
            point.prePoint = _curP;
            [self.openList addObject:point];
        }
        
        //当前点的上
        if (p.y>0 && ![self hasPoint:CGPointMake(p.x, p.y-1)]) {
            AStarPoint *point = [[AStarPoint alloc] init];
            point.point = CGPointMake(p.x, p.y-1);
            point.direction = 1;
            point.prePoint = _curP;
            [self.openList addObject:point];
        }
        
        //当前点的下
        if (p.y<6 && ![self hasPoint:CGPointMake(p.x, p.y+1)]) {
            AStarPoint *point = [[AStarPoint alloc] init];
            point.point = CGPointMake(p.x, p.y+1);
            point.direction = 3;
            point.prePoint = _curP;
            [self.openList addObject:point];
        }
        
        //如果没有任何元素被添加到openList 说明无路可走了
        if (self.openList.count == 0) {
            NSLog(@"无法到达目的地");
            break;
        }
        
        //找出可选点中的最短点 并且移动到该点
        int tem = INT_MAX;
        for (AStarPoint *point in self.openList) {
            CGPoint pt = point.point;
            int g = fabs(pt.x-_curP.point.x)+fabs(pt.y-_curP.point.y);
            int h = fabs(pt.x-e.x)+fabs(pt.y-e.y);
            
            //如果最小
            if (g+h<tem) {
                tem = g+h;
                //移动到该点
                _curP = point;
            }
        }
        
        [self.openList removeObject:_curP];
        [self.closeList addObject:_curP];
   
    }
    
    //倒叙找出路径
    NSMutableArray *realPath = [NSMutableArray array];
    AStarPoint *eP = self.closeList.lastObject;
    [realPath addObject:eP];
    
    //如果不是开始点
    while (!CGPointEqualToPoint(eP.prePoint.point, self.startPoint)) {
        [realPath addObject:eP.prePoint];
        eP = eP.prePoint;
    }
    
    [realPath addObject:eP.prePoint];
    
    self.closeList = realPath;
    
    //绘制路径
    [self setNeedsDisplay];
}

- (BOOL)hasPoint:(CGPoint)p
{
    //这个是墙
    if (_map[(int)(p.x)][(int)(p.y)]==1) {
        return YES;
    }
    
    //在open中
    for (AStarPoint *point in self.openList) {
        if (CGPointEqualToPoint(p, point.point)) {
            return YES;
        }
    }
    
    //在close中
    for (AStarPoint *point in self.closeList) {
        if (CGPointEqualToPoint(p, point.point)) {
            return YES;
        }
    }
    
    return NO;
}

@end
