//
//  WebService.h
//  ARC enabled
//  Created by Hooman Ahmadi on 12/27/11.
/****************************************************************************************************************************
 For any class using a WebService object for asynchronous calls...
 
 1) Define a notification observer in the init method of that class:
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(methodUsingParsedData:) name:@"className" object:nil];
 
 2) This class must also define methodUsingParsedData to receive and use the data once the api request is completed.
 Initialize the WebService object in the following way: WebService *ws = [[WebService alloc] initWithObjectName:@"className"];
 
 In all cases, you must define myWebsite as http://www.website.com/webroot (the url of your api) in WebService.m (this file)
 
 WebService use cases:
 
 NSString *postPath = @"path/of/api/call"
 NSString *postVal = @"key1=value1&key2=value2&key3=value3";
 
 WebService *wsSync = [[WebService alloc] init];
 NSDictionary *fetchedData = [wsSync fetchJSON:postPath];
 NSDictionary *postedData = [wsSync postJSON:postPath valuePair:postVal];
 
 WebService *wsAsync = [[WebService alloc] initWithObjectName:@"className"];
 NSDictionary *fetchedData = [wsAsync fetchJSON:postPath];
 NSDictionary *postedData = [wsAsync postJSON:postPath valuePair:postVal];
 ****************************************************************************************************************************/ 

#import <Foundation/Foundation.h>

@interface WebService : NSObject <NSURLConnectionDelegate>
{
    NSDictionary *parsedData;
    NSMutableData *receivedData;
    NSString *objectName;
}

@property (nonatomic, readonly) NSDictionary *parsedData;

- (NSDictionary *)fetchJSON:(NSString *)urlString;
- (NSDictionary *)postJSON:(NSString *)urlString valuePair:(NSString *)pairString;

- (void)fetchJSONasync:(NSString *)urlString;
- (void)postJSONasync:(NSString *)urlString valuePair:(NSString *)pairString;

- (id)initWithObjectName:(NSString *)name;
@end
