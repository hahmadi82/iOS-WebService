iOS-WebService
==============

simple Objective-C class for handing synchronous and asynchronous web service calls

 For any class using a WebService object for asynchronous calls...
 
 1) Define a notification observer in the init method of that class:
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(methodUsingParsedData:) name:@"className" object:nil];
 
 2) This class must also define methodUsingParsedData to receive and use the data once the api request is completed.
 Initialize the WebService object in the following way:
 
    WebService *ws = [[WebService alloc] initWithObjectName:@"className"];
 
 In all cases, you must define myWebsite as http://www.website.com/webroot (the url of your api) in WebService.m
 
 WebService Use Cases:
======================
    NSString *postPath = @"path/of/api/call"
    NSString *postVal = @"key1=value1&key2=value2&key3=value3";
 
    WebService *wsSync = [[WebService alloc] init];
    NSDictionary *fetchedData = [wsSync fetchJSON:postPath];
    NSDictionary *postedData = [wsSync postJSON:postPath valuePair:postVal];
 
    WebService *wsAsync = [[WebService alloc] initWithObjectName:@"className"];
    NSDictionary *fetchedData = [wsAsync fetchJSON:postPath];
    NSDictionary *postedData = [wsAsync postJSON:postPath valuePair:postVal];