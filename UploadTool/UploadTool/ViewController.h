//
//  ViewController.h
//  UploadTool
//
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "InstantPuddingWrapper.h"
#import "PDCA.h"
#import "File.h"
#import "Connect.h"
#import "customerAPI/Connect.h"
#import "OVitem.h"
#import "Common.h"
#include <AppKit/AppKit.h>
#import "InstantPudding_API.h"

@interface ViewController : NSViewController
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
    
    NSTreeNode *_rootTreeNode;
    NSString *_finalResult;
    NSString * SerialNumber;
    
    

}

int IP_getPdcaHandle(IP_UUTHandle *UID);
int IP_insertAttribute(IP_UUTHandle a_UID, const char *ap_name, NSString *ap_attr);
int IP_insertTestItemAndResult(IP_UUTHandle a_UID, NSString *ap_TestName, NSString *ap_LowLimit, NSString *ap_UpLimit, char *ap_Units, int ap_Priority, NSString *ap_testValue, NSString *ap_testMessage, bool isPass);
int IP_commitData(IP_UUTHandle a_UID, bool a_bTotalPass);
int IP_commitData_audit(IP_UUTHandle a_UID, bool a_bTotalPass);
int IP_fail_releaseUUT(IP_UUTHandle a_UID);
int IP_addFile(IP_UUTHandle a_UID, NSString *input, NSString *description);

//make a general api to use
NSString *IP_getGroundHogStationInfo(enum IP_ENUM_GHSTATIONINFO StationInfo);

int CheckFatalError(IP_UUTHandle a_UID, NSString *sn, NSString **retValue);

bool isValidResult(NSString *aInput);


- (void)Run;
- (void)initPdcaHandle;
- (void)_PDCA_START_PHASE;
- (void)_PDCA_END_PHASE;
- (BOOL)getInformationFromPlist;

@end
