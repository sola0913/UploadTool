//
//  PDCA.h
//  UploadTool
//
//


#import <Foundation/Foundation.h>
#import "InstantPuddingWrapper.h"
//#import "InstantPudding_API.h"
#import "File.h"

enum RESULTSTATUS
{
    STATUS_FAIL = 0, // test failed
    
    STATUS_PASS,  // test passed
    
    STATUS_NA
    
};

@interface PDCA : NSObject
{
@private
    IP_UUTHandle UID;
    NSString * Path;
    NSString * AbsolutePath;
    NSString * NameOfPDCA;
    bool ResultStatus;
    NSString * Result;
    NSString * SN;
    
    File * file;
}


- (NSUInteger) updateToPDCA:(NSString *)path sn:(NSString *)sn result:(NSString *)result;

@end
