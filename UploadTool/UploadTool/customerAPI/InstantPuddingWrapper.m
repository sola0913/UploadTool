//
//  InstantPuddingWrapper.m
//  UploadTool
//
//

#import "InstantPuddingWrapper.h"

int IP_getPdcaHandle(IP_UUTHandle *UID)
{
    if(UID == nil)
    {
        return -1;
    }
    
    //## required step #1:  IP_UUTStart()
    IP_API_Reply reply = IP_UUTStart(UID);
    if (!IP_success(reply))
    {
        IP_UUTCancel(UID);     //MUST CALL HERE TO CLEAN THE BRICKS
        IP_UID_destroy(UID);
        IP_reply_destroy(reply);
        return -1;             // do the appropriate thing here according to your needs
    }
//    IP_reply_destroy(reply);
    
    NSLog(@"### IP_getPdcaHandle executed.###");
    return 0;
}


int IP_insertAttribute(IP_UUTHandle a_UID, const char *ap_name, NSString *ap_attr)
{
    const char *mATTR = [ap_attr UTF8String];
    const char *mName = ap_name;
    IP_API_Reply reply;
    
    
    if(a_UID == nil || ap_attr == nil || ap_name == nil)
    {
        return -1;
    }
    
    
    if(strlen(ap_name) == 0 || [ap_attr length] == 0)
    {
        return -1;
    }
    
    reply = IP_addAttribute( a_UID, mName, mATTR);
    
    if (!IP_success(reply))
    {
        IP_UUTCancel(a_UID); //MUST CALL HERE TO CLEAN THE BRICKS
        IP_UID_destroy(a_UID);
        IP_reply_destroy(reply);
        return -1;
    }
//    IP_reply_destroy(reply);
    
    NSLog(@"### IP_insertAttribute have been executed. ###");
    return 0;
}


int IP_insertTestItemAndResult(IP_UUTHandle a_UID, NSString *ap_TestName, NSString *ap_LowLimit, NSString *ap_UpLimit, char *ap_Units, int ap_Priority, NSString *ap_testValue, NSString *ap_testMessage, bool isPass)
{
    
    IP_TestSpecHandle testSpec;
    IP_TestResultHandle testResult;
    IP_API_Reply reply;
    
    if(a_UID == nil || ap_TestName == nil || ap_LowLimit == nil || ap_UpLimit == nil || ap_testValue == nil || ap_testMessage == nil || ap_Units == nil)
    {
        return -1;
    }
    
    if(!isValidResult(ap_testValue))
    {
        return -1;
    }
    
    if([ap_TestName length] == 0)
    {
        return -1;
    }
    
    const char *TEST_NAME = [ap_TestName UTF8String];
    const char *TEST_LOW_LIMIT = [ap_LowLimit UTF8String];
    const char *TEST_UP_LIMIT = [ap_UpLimit UTF8String];
    // TODO: currently the priority are all 0
    // const char *TEST_PRIORITY = "0";
    
    // create a test specification for our first test, Rubberband stretching
    testSpec = IP_testSpec_create();
    if(NULL != testSpec)
    {
        BOOL APIcheck = false;
        APIcheck = IP_testSpec_setTestName( testSpec, TEST_NAME, strlen(TEST_NAME));
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            return -1;
        }
        
        //IP_testSpec_setSubTestName( testSpec, "Stretch\0", 8);
        //IP_testSpec_setSubSubTestName( testSpec, "Long Dimension\0", 15 );
        APIcheck = IP_testSpec_setLimits( testSpec, TEST_LOW_LIMIT, strlen(TEST_LOW_LIMIT), TEST_UP_LIMIT, strlen(TEST_UP_LIMIT));
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            return -1;
        }
        
        // If units not set. skip it.
        if(strlen(ap_Units) != 0)
        {
            APIcheck = IP_testSpec_setUnits( testSpec, ap_Units, strlen(ap_Units) );
            if(!APIcheck)
            {
                IP_testSpec_destroy(testSpec);
                return -1;
            }
        }

        if((ap_Priority == IP_PRIORITY_STATION_CALIBRATION_AUDIT) || (ap_Priority>=IP_PRIORITY_REALTIME_WITH_ALARMS && ap_Priority<=IP_PRIORITY_ARCHIVE))
        {
            APIcheck = IP_testSpec_setPriority( testSpec, ap_Priority );
        }
        else
        {
            return -1;
        }
        
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            return -1;
        }
    }
    
    const char *TEST_VALUE = [ap_testValue UTF8String];
    const char *TEST_MESSAGE = [ap_testMessage UTF8String];
    
    testResult = IP_testResult_create();
    if(isPass)
    {
        BOOL APIcheck = false;
        APIcheck = IP_testResult_setResult( testResult, IP_PASS );
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            IP_testResult_destroy(testResult);
            return -1;
        }
        APIcheck = IP_testResult_setValue( testResult, TEST_VALUE, strlen(TEST_VALUE));
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            IP_testResult_destroy(testResult);
            return -1;
        }
    
        APIcheck = IP_testResult_setMessage(testResult, TEST_MESSAGE, strlen(TEST_MESSAGE));
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            IP_testResult_destroy(testResult);
            return -1;
        }
    }
    else
    {
        BOOL APIcheck = false;
        APIcheck = IP_testResult_setResult( testResult, IP_FAIL );
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            IP_testResult_destroy(testResult);
            return -1;
        }
        APIcheck = IP_testResult_setValue( testResult, TEST_VALUE, strlen(TEST_VALUE));
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            IP_testResult_destroy(testResult);
            return -1;
        }
        APIcheck = IP_testResult_setMessage( testResult, TEST_MESSAGE, strlen(TEST_MESSAGE));
        if(!APIcheck)
        {
            IP_testSpec_destroy(testSpec);
            IP_testResult_destroy(testResult);
            return -1;
        }
    }
    
    //## required step #2:  IP_addResult()
    reply = IP_addResult(a_UID, testSpec, testResult );
    if ( !IP_success( reply ) )
    {
        IP_testResult_destroy(testResult);
        IP_testSpec_destroy(testSpec);
        IP_reply_destroy(reply);

        return -1;
    }
//    IP_reply_destroy(reply);
    IP_testResult_destroy(testResult);
    IP_testSpec_destroy(testSpec);
    return 0;
}


int IP_commitData(IP_UUTHandle a_UID, bool a_bTotalPass){
    IP_API_Reply reply;
    IP_API_Reply commitReply;
    
    if(a_UID == nil)
    {
        return -1;
    }
    
    //## required step #3:  IP_UUTDone()
    reply = IP_UUTDone(a_UID);
    IP_reply_destroy(reply);
    
    //## required step #4:  IP_UUTCommit()
    if(a_bTotalPass){
        NSString *cmdZip = @"open /Users/gdlocal/Desktop/";
        system([cmdZip UTF8String]);
        commitReply = IP_UUTCommit( a_UID, IP_PASS );
    }
    else
    {
        NSString *cmdZip1 = @"open /Users/gdlocal/Documents/";
        system([cmdZip1 UTF8String]);
        commitReply = IP_UUTCommit( a_UID, IP_FAIL );
    }
    
    NSString *cmdZip22 = @"open /Users/gdlocal/Download/";
    system([cmdZip22 UTF8String]);
    if ( !IP_success( commitReply ) )
    {
    }
    IP_reply_destroy( commitReply );
    IP_UID_destroy( a_UID );
    
    return 0;
}

//Added audit mode test
int IP_commitData_audit(IP_UUTHandle a_UID, bool a_bTotalPass)
{
    IP_API_Reply reply;
    IP_API_Reply commitReply;
    
    if(a_UID == nil)
    {
        return -1;
    }
    
    //## required step #3:  IP_UUTDone()
    reply = IP_UUTDone(a_UID);

    IP_reply_destroy(reply);
    
    //## required step #4:  IP_UUTCommit()
    if(a_bTotalPass)
    {
        commitReply = IP_UUTCommit(a_UID, IP_PASS);
    }
    else
    {
        commitReply = IP_UUTCommit(a_UID, IP_FAIL);
    }
    
    if ( !IP_success( commitReply ) )
    {
        
    }
    IP_reply_destroy( commitReply );
    IP_UID_destroy( a_UID );
    return 0;
}


int IP_addFile(IP_UUTHandle a_UID, NSString *input, NSString *description)
{
    const char *fileInput = [input UTF8String];
    const char *fileDescription = [description UTF8String];
    IP_API_Reply reply;
    
    if(a_UID == nil)
    {
        return -1;
    }
    
    // now, submit the blob
    reply = IP_addBlob(a_UID, fileDescription, fileInput);
    if (!IP_success( reply))
    {
        IP_reply_destroy(reply);
        return -1;
    }
    
    // clean up
    IP_reply_destroy(reply);
    return 0;
}


int IP_fail_releaseUUT(IP_UUTHandle a_UID)
{
    if(a_UID == nil)
    {
        return -1;
    }
    
    IP_UUTCancel(a_UID); //MUST CALL HERE TO CLEAN THE BRICKS
    IP_UID_destroy(a_UID);
    
    return 0;
}


NSString *IP_getGroundHogStationInfo(enum IP_ENUM_GHSTATIONINFO StationInfo)
{
    IP_UUTHandle UID;
    
    IP_API_Reply reply = IP_UUTStart(&UID);
    if ( !IP_success(reply) )
    {
        printf("[IPWrapper] Error from getPdcaHandle() for Unit : %s\n", IP_reply_getError(reply));
        IP_UUTCancel(UID);     //MUST CALL HERE TO CLEAN THE BRICKS
        IP_UID_destroy(UID);
        IP_reply_destroy(reply);
        return @"";       // do the appropriate thing here according to your needs
    }
    IP_reply_destroy(reply);
    
    size_t length;
    IP_API_Reply attribRep = IP_getGHStationInfo(UID,StationInfo,NULL,&length);//make sure first time you pass NULL for buffer
    if (!IP_success(attribRep))
    {
        printf("[IPWrapper] Error from First call IP_getGHStationInfo(): %s\n", IP_reply_getError(attribRep));
        IP_UID_destroy(UID);
        IP_reply_destroy(attribRep);
        return @"";
    }
    IP_reply_destroy(attribRep);
    
    char *cpProduct = malloc(sizeof(char) * (length+1) );
    attribRep = IP_getGHStationInfo(UID,StationInfo,&cpProduct, &length);
    if ( !IP_success( attribRep ) )
    {
        printf("[IPWrapper] Error from second call IP_getGHStationInfo(): %s\n", IP_reply_getError(attribRep));
        IP_UID_destroy(UID);
        IP_reply_destroy(attribRep);
        return @"";
    }
    
    // Memory Leak
    IP_UID_destroy(UID);
    IP_reply_destroy(attribRep);
    
    NSString *retString = [[NSString alloc] initWithCString:cpProduct encoding:NSASCIIStringEncoding];
    
    if (NULL != cpProduct)
    {
        free(cpProduct);
        cpProduct = NULL;
    }
    
    return retString;
}


int CheckFatalError(IP_UUTHandle a_UID, NSString *sn, NSString **retValue)
{
    const char *SN_VALUE = [sn UTF8String];
    IP_API_Reply reply = IP_amIOkay(a_UID, SN_VALUE);

    if (!IP_success(reply))
    {
        *retValue = [NSString stringWithFormat:@"%s", IP_reply_getError(reply)];
        IP_reply_destroy(reply);
        return -1;
    }
    IP_reply_destroy(reply);
   
    return 0;
}

bool isValidResult(NSString *aInput)
{
    NSString *mValidChar = @"0123456789.-+eE";
    int i = 0;
    int j = 0;

    for(i = 0; i < [aInput length]; i++)
    {
        char c = [aInput characterAtIndex:i];
        bool match = false;
    
        for(j = 0; j < [mValidChar length]; j++)
        {
            char cValidchar = [mValidChar characterAtIndex:j];
        
            if(c == cValidchar)
            {
                match = true;
                break;
            }
        }
        
        if(!match)
        {
            return false;
        }
    }

    return true;
}
