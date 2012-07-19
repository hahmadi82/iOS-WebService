//
//  WebService.m
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
 
#import "WebService.h"

#define myWebsite @"http://www.website.com/webroot"

@implementation WebService
@synthesize parsedData;

/****************************************************************************************************************************
 objectName is set by the class instantiating this object. This string is later used for the notification center request.
 Set myWebsite to the domain/webroot of the api providing the data. 
****************************************************************************************************************************/
- (id)initWithObjectName:(NSString *)className
{
    self = [super init];
    
    if (self) {
        objectName = className;
    }
    
    return self;
}

/****************************************************************************************************************************
 POST to the api method, synchronously, using the urlPath and pairString (query string) parameters.
 Once the request is set up, we do a synchronous url connection to get the api data. Once the data is received,
 we parse the JSON into an NSDictionary for ease of use.
****************************************************************************************************************************/
- (NSDictionary *)postJSON:(NSString *)urlPath valuePair:(NSString *)pairString
{
    //The pairString is converted to NSData and urlPath is appended to the string containing your website path.
    NSData *myRequestData = [NSData dataWithBytes: [pairString UTF8String] length: [pairString length]];
    NSMutableString *domain = [[NSMutableString alloc] initWithString:myWebsite];
    [domain appendString:urlPath];
    
    //Initialize the mutable URL request to do a POST with the requestData created from the pairString. 
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:domain]];
    [req setHTTPMethod: @"POST"];
    [req setHTTPBody: myRequestData];
    
    //Return the data synchronously and convert the JSON to an NSDictionary.
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    parsedData = [NSJSONSerialization
                  JSONObjectWithData:returnedData
                  options:NSJSONReadingMutableLeaves
                  error:nil];
    
    return parsedData;
}

/****************************************************************************************************************************
 Fetch JSON from the api method, synchronously, using the urlPath.
 Once the request is set up, we do a synchronous url connection to get the api data. Once the data is received,
 we parse the JSON into an NSDictionary for ease of use.
****************************************************************************************************************************/
- (NSDictionary *)fetchJSON:(NSString *)urlPath
{   
    
    //Appended to the string containing your website path.
    NSMutableString *domain = [[NSMutableString alloc] initWithString:myWebsite];
    [domain appendString:urlPath];
    
    //Create an NSURLRequest using the url domain and path. 
    NSURL *url = [NSURL URLWithString:domain];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    //Return the data synchronously and convert the JSON to an NSDictionary.
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    parsedData = [NSJSONSerialization
                  JSONObjectWithData:data
                  options:NSJSONReadingMutableLeaves
                  error:nil];
    
    return parsedData;
}

/****************************************************************************************************************************
 POST to the api method, asynchronously, using the urlPath and pairString (query string) parameters.
 Once the request is set up, we do an asynchronous url connection to gathers the api data through the
 NSURLConnectionDelegate protocol methods defined in this class.
 ****************************************************************************************************************************/
- (void)postJSONasync:(NSString *)urlPath valuePair:(NSString *)pairString
{
    //The pairString is converted to NSData and urlPath is appended to the string containing your website path.
    NSData *myRequestData = [NSData dataWithBytes: [pairString UTF8String] length: [pairString length]];
    NSMutableString *domain = [[NSMutableString alloc] initWithString:myWebsite];
    [domain appendString:urlPath];
    
    //Initialize the mutable URL Request to do a POST with the requestData created from the pairString. 
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:domain]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    [req setHTTPMethod: @"POST"];
    [req setHTTPBody: myRequestData];

    //Create an asynchronous url connection that calls the delegate methods defined below.
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (theConnection) {
        receivedData = [NSMutableData data];
    } else {
        //put UIAlert here if needed
        NSLog(@"Failed to post!");
    }
}

/****************************************************************************************************************************
 Fetch JSON from the api method, synchronously, using the urlPath.
 Once the request is set up, we do an asynchronous url connection to gathers the api data through the
 NSURLConnectionDelegate protocol methods defined in this class.
****************************************************************************************************************************/
- (void)fetchJSONasync:(NSString *)urlPath
{
    //Appended to the string containing your website path.
    NSMutableString *domain = [[NSMutableString alloc] initWithString:myWebsite];
    [domain appendString:urlPath];
    NSURL *url = [NSURL URLWithString:domain];
    
    //Create an NSURLRequest using the url domain and path.
    NSURLRequest *req=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];

    //Create an asynchronous url connection that calls the delegate methods defined below.
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (theConnection) {
        receivedData = [NSMutableData data];
    } else {
        //put UIAlert here if needed
        NSLog(@"Failed to fetch!");
    }
}

/****************************************************************************************************************************
 This method is called when the server has determined that it has enough information to create the NSURLResponse.
 It can be called multiple times, for example in the case of a redirect, so each time we reset the data.
****************************************************************************************************************************/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

/****************************************************************************************************************************
 Append the incoming data to receivedData as it comes in.
****************************************************************************************************************************/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

/****************************************************************************************************************************
 Display an error if the connection fails. You can add a UIAlert here to notify the user directly.
****************************************************************************************************************************/
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

/****************************************************************************************************************************
 Once the received data is complete, convert the JSON to an NSDictionary, and send parsedData with the notification center
 to the class that created this object and defined a method to utilize the api data.
****************************************************************************************************************************/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    parsedData = [NSJSONSerialization
                  JSONObjectWithData:receivedData
                  options:NSJSONReadingMutableLeaves
                  error:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:objectName object:parsedData];
}

@end
