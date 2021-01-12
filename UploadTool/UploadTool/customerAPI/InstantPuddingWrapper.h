//
//  InstantPuddingWrapper.h
//  UploadTool
//
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>

#import "InstantPudding_API.h"

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
