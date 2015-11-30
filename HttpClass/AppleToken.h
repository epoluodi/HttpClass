//
//  AppleToken.h
//  HttpClass
//
//  Created by 程嘉雯 on 15/5/29.
//  Copyright (c) 2015年 com.epoluodi.lib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "info.h"
#import "HttpClass.h"

#define AppleTokenUrl @"http://epoluodi.vicp.cc:9099/PushServer.asmx/submitAppleToken"



@interface AppleToken : NSObject<NSXMLParserDelegate>
{
    NSMutableString *returndata;
}

-(BOOL)submitAppleDeviceInfo:(AppleDeviceInfoStruct *)appdeivceinfo APPID:(NSString *)appid;


@end
