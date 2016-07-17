//
//  HttpClass.m
//  HttpClass
//
//  Created by 程嘉雯 on 15/5/27.
//  Copyright (c) 2015年 com.epoluodi.lib. All rights reserved.
//

#import "HttpClass.h"

#define HTTP_CONTENT_BOUNDARY @"WANPUSH"



@implementation HttpClass
@synthesize WebServiceUrl;


-(instancetype)init
{
    mutableArrary = [[NSMutableArray alloc] init];
    return [super init];
}

-(instancetype)init:(NSString *)url
{
    WebServiceUrl =url;
    return [self init];
    
}

-(void)clearArray
{
    [mutableArrary removeAllObjects];
}
-(void)addParamsString:(NSString *)key values:(NSString *)values
{
    NSString *part = [NSString stringWithFormat: @"%@=%@", key, values];
    [mutableArrary addObject:part];
}

-(NSData *)getDataForArrary
{
    NSString *encodedDictionary = [mutableArrary componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

-(NSData*)dataEncodeDictionary:(NSDictionary*)dictionary {
    [mutableArrary removeAllObjects];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [mutableArrary addObject:part];
    }
    NSString *encodedDictionary = [mutableArrary componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}



-(NSData *)httprequest:(NSData *)body
{


    //定义NSMutableURLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:WebServiceUrl]];
    [request setTimeoutInterval:15];
    
    
    //设置提交方式为 POST
    [request setHTTPMethod:@"POST"];
    //设置http-header:Content-Type
    //这里设置为 application/x-www-form-urlencoded ，如果设置为其它的，比如text/html;charset=utf-8，或者 text/html 等，都会出错。不知道什么原因。
//    [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //计算POST提交数据的长度

        NSString *postLength = [NSString stringWithFormat:@"%d",[body length]];
        NSLog(@"postLength=%@",postLength);
        //设置http-header:Content-Length
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        //设置需要post提交的内容
        [request setHTTPBody:body];
    
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"ran out of money" forKey:NSLocalizedDescriptionKey];
    
    
    //定义
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (error.code !=0)
        return nil;
    
    //将NSData类型的返回值转换成NSString类型
//    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSString *result = [[NSString alloc] initWithData:responseData encoding:gbkEncoding];
//    NSLog(@"code:%d",urlResponse.statusCode);
//    NSLog(@"user login check result:%@",result);
  
    
    return responseData;
}

-(NSData*)UploadFile:(NSString *)filename FileData:(NSData *)data
{
 
    NSURL* url = [NSURL URLWithString:WebServiceUrl];
    NSString* strBodyBegin = [NSString stringWithFormat:@"--%@\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\nContent-Type: %@\n\n", HTTP_CONTENT_BOUNDARY, @"file",  filename, @"jpg"];
    NSString* strBodyEnd = [NSString stringWithFormat:@"\n--%@--",HTTP_CONTENT_BOUNDARY];
    
    NSMutableData *httpBody = [NSMutableData data];
    [httpBody appendData:[strBodyBegin dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[strBodyEnd dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest* httpPutRequest = [[NSMutableURLRequest alloc] init];
    [httpPutRequest setURL:url];
    [httpPutRequest setHTTPMethod:@"POST"];
    [httpPutRequest setTimeoutInterval: 60000];
    [httpPutRequest setValue:[NSString stringWithFormat:@"%@", @(httpBody.length)] forHTTPHeaderField:@"Content-Length"];
    [httpPutRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",HTTP_CONTENT_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    httpPutRequest.HTTPBody = httpBody;
    
    NSHTTPURLResponse* httpResponse = nil;
    NSError *error =nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:httpPutRequest returningResponse:&httpResponse error:&error];
    if (error.code !=0)
        return nil;
   
    return responseData;
}

+(NSString *)httprequestForGet:(NSString *)url
{
    
    
    //定义NSMutableURLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:15];
    

    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"ran out of money" forKey:NSLocalizedDescriptionKey];
    
    //定义
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    //同步提交:POST提交并等待返回值（同步），返回值是NSData类型。
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (error.code !=0)
        return nil;
    if (urlResponse.statusCode ==200)
    {
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *result = [[NSString alloc] initWithData:responseData encoding:gbkEncoding];
//        NSLog(@"返回数据：%@",result);
        return result;
    }
    
    return nil;
}



-(BOOL)httprequest:(NSData *)body delegate:( NSObject<Httpdelegate> *)delegate
{
    
    //计算POST提交数据的长度
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[body length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:WebServiceUrl]];
    request.timeoutInterval=30;
    
    //设置提交方式为 POST
    [request setHTTPMethod:@"POST"];

    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //设置需要post提交的内容
    [request setHTTPBody:body];
    
    viewdelegate=delegate;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection)
        return YES;
    else
        return NO;
    
}


#pragma mark - NSURLConnectionDataDelegate
#pragma mark 接收到服务器返回的数据时调用（如果数据比较多，这个方法可能会被调用多次）
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"接收到服务器返回的数据");
    // 拼接数据
    [recivedata appendData:data];
}

#pragma mark 网络连接出错时调用
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"网络连接出错:%@", [error localizedDescription]);
    [viewdelegate httpFail];
    
}
#pragma mark 服务器的数据已经接收完毕时调用
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"服务器的数据已经接收完毕");
    // 解析成字符串数据
    NSString *str = [[NSString alloc] initWithData:recivedata encoding:NSUTF8StringEncoding ];
    NSLog(@"json %@", str);
    [viewdelegate reposenHttp:str];
}


-(NSString *)getXmlString:(NSData *)data
{
    
    
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate =self;
    if ([parser parse])
        return xmlstring;
    else
        return nil;
    
}

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    xmlstring = [[NSMutableString  alloc] init];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}
//step 3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    [xmlstring appendString:string];
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





@end
