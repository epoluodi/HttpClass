//
//  AppleToken.m
//  HttpClass
//
//  Created by 程嘉雯 on 15/5/29.
//  Copyright (c) 2015年 com.epoluodi.lib. All rights reserved.
//

#import "AppleToken.h"

@implementation AppleToken


-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    returndata = [[NSMutableString  alloc] init];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}

//step 3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    [returndata appendString:string];
}

//step 4 ：解析完当前节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
 
}

//step 5；解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd) );
}
//获取cdata块数据
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd) );
}


-(BOOL)submitAppleDeviceInfo:(AppleDeviceInfoStruct *)appdeivceinfo APPID:(NSString *)appid
{
    HttpClass * httpclass = [[HttpClass alloc] init:AppleTokenUrl];
    NSString *apple_token = [NSString stringWithUTF8String:appdeivceinfo->Apple_Token];
    NSString *apple_model = [NSString stringWithUTF8String:appdeivceinfo->apple_Model];
    NSString *apple_uuid = [NSString stringWithUTF8String:appdeivceinfo->apple_uuid];
    NSString *apple_system_name = [NSString stringWithUTF8String:appdeivceinfo->apple_syatem_name];
    NSString *apple_system_ver = [NSString stringWithUTF8String:appdeivceinfo->apple_system_ver];
    
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                apple_token,@"apple_token",
                                apple_model,@"apple_model",
                                apple_uuid,@"apple_uuid",
                                apple_system_name,@"apple_system_name",
                                apple_system_ver,@"apple_system_ver",
                                nil];
    NSData *jsondata =[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonstr = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    NSLog(@"json结果 %@",jsonstr);
    [httpclass addParamsString:@"appCode" values:appid];
    [httpclass addParamsString:@"json" values:jsonstr];
    NSData * data = [httpclass httprequest:[httpclass getDataForArrary]];
    
    if (data == nil )
        return NO;
    else{
        
        NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
        parser.delegate =self;
        if ([parser parse])
        {
            
            NSData *xmldata = [returndata dataUsingEncoding:NSUTF8StringEncoding];
               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:xmldata options:NSJSONReadingMutableLeaves error:nil];
            if ([[json objectForKey:@"return"] isEqualToString:@"ok"])
                return YES;
            else
                return NO;
            
        }
        else
        {
            return NO;
        }
    }
    
}


@end
