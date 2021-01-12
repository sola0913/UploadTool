//
//  Connect.h
//  UploadTool
//
//

#import <Foundation/Foundation.h>
#import "PDCA.h"
#import "File.h"
#import "Connect.h"


@protocol FPCallbackView <NSObject>
- (BOOL)showToTableView:(NSString *)fileName status:(NSString *)status row:(NSUInteger)row;

@end

@interface control : NSObject
{
    NSString * stationName;
    NSString * appVersion;
    NSString * appName;
    NSString * readPath;
    NSString * savePath;
    NSString * backupsPath;
    NSString * reportPath;
    NSString * documentPath;
    NSString * mountCommand;
    NSString * fileName;
    NSString * saveCSVFileNamePath;
    NSString * saveCSVFileName;
    NSString * saveLOGFileName;
    NSString * documentFileName;
    NSString * buffer;
    NSString * datePath;
    
    NSString * Result;
    NSString * AbsolutePath;
    NSString * SN;
    NSString * NameOfPDCA;
    BOOL ResultStatus;
    
    NSThread * thread;
    NSThread * threadConnect;
    
    NSString * zipFileName;
    NSString * zipFilePath;
    
    NSString * dateAndtime;
    NSString * AppStartTime;
    NSString * sn;
    NSString * testTime;
    NSString * line;
    NSString * status;
    NSArray * allItem;
    NSMutableArray * allUpper;
    NSMutableArray * allLower;
    NSArray * allMeasurement;
    NSArray * allResultAndPass;
    NSMutableArray * allResult;
    NSMutableArray * allValue;
    NSUInteger count;
    
    NSString * result;
    
    NSInteger totalCount;
    NSInteger failCount;
    
    NSString * message;
    
    char * measurement;
    
    IP_UUTHandle UID;
    bool isPass;
    
    NSUInteger row;
    NSString * commitedPdcaStatus;
    NSString * IPAddress;
    NSString * command;
    NSString * timeout;
    BOOL ConnectStatus;
    
    NSString * SourceDirectory;
}

- (void)Run;

@property (weak) id <FPCallbackView> delegate;
@end
