//
//  ViewController.m
//  strong&&copy理解demo
//
//  Created by 姜卫 on 2019/8/7.
//  Copyright © 2019 Martin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic , strong) NSString *strongstr;
@property (nonatomic , copy) NSString *copystr;
    
@end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *   situation 1
     *   不可变初始化，全局变量赋值
     *   因为是全局变量直接赋值，不会调用setter方法，所以这里strong和copy都不生效
     */
    NSString *str1 = [NSString stringWithFormat:@"hello"];
    _strongstr = str1;
    _copystr = str1;
    NSLog(@"       对象地址          对象指针地址       对象的值   ");
    NSLog(@"str1 == %p, &str1 == %p, str1 == %@",str1,&str1,str1);
    NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
    NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
    
    /**
     *  situation 2
     *  NSString子类NSMutableString进行赋值，依旧全局变量进行赋值
     *  因为是全局变量直接赋值，即使指向的是可变变量NSMutableString并且调用局部变量的setter方法，但依旧不会调用全局变量的setter方法，所以这里strong和copy依旧不生效
     */
    NSMutableString *str2 = [[NSMutableString alloc] initWithString:@"hello2"];
    _strongstr = str2;
    _copystr = str2;
    [str2 setString:@"what2"];
    NSLog(@"       对象地址          对象指针地址       对象的值   ");
    NSLog(@"str2 == %p, &str2 == %p, str2 == %@",str2,&str2,str2);
    NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
    NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
    
    /**
     *  situation 3
     *  NSString子类NSMutableString进行赋值，改用self.指针进行赋值
     *  strong的setter只是进行了retain操作，引用计数+1，对象地址指向str3地址，str3变值也会相应变值
     *  copy的setter会对str3进行[str3 copy]深拷贝操作，重新生成了新对象，str3变值不会影响copy对象
     */
    NSMutableString *str3 = [[NSMutableString alloc] initWithString:@"hello3"];
    self.strongstr = str3;
    self.copystr = str3;
    
    [str3 setString:@"what3"];
    NSLog(@"       对象地址          对象指针地址       对象的值   ");
    NSLog(@"str3 == %p, &str3 == %p, str3 == %@",str3,&str3,str3);
    NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
    NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
    
    /**
     *  situation 4
     *  不可变类型NSString进行赋值，改用self.指针进行赋值
     *  因为是不可变类型，这里copy就只是浅拷贝，没有新生成对象，只是拷贝了指针
     */
    NSString *str4 = [NSString stringWithFormat:@"hello4"];
    self.strongstr = str4;
    self.copystr = str4;
    NSLog(@"       对象地址          对象指针地址       对象的值   ");
    NSLog(@"str4 == %p, &str4 == %p, str4 == %@",str4,&str4,str4);
    NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
    NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
    
}


@end
