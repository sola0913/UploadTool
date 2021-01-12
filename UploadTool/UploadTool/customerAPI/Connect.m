//
//  Connect.m
//  UploadTool
//
//

#import "Connect.h"

@implementation control

- (id)init
{
    self = [super init];
    if (self)
    {
        
        readPath            = [[NSString alloc] init];
        savePath            = [[NSString alloc] init];
        backupsPath         = [[NSString alloc] init];
        reportPath          = [[NSString alloc] init];
        documentPath        = [[NSString alloc] init];
        mountCommand        = [[NSString alloc] init];
        
        fileName            = [[NSString alloc] init];
        buffer              = [[NSString alloc] init];
        datePath            = [[NSString alloc] init];
        
        sn                  = [[NSString alloc] init];
        status              = [[NSString alloc] init];
        result              = [[NSString alloc] init];
        
        saveCSVFileNamePath = [[NSString alloc] init];
        saveCSVFileName     = [[NSString alloc] init];
        documentFileName    = [[NSString alloc] init];
        
        message             = [[NSString alloc] init];
        zipFileName         = [[NSString alloc] init];
        zipFilePath         = [[NSString alloc] init];
        dateAndtime         = [[NSString alloc] init];
        
        row = 0;
        count = 0;
        commitedPdcaStatus  = [[NSString alloc] init];
        totalCount = 0;
        failCount = 0;
        
        IPAddress = [[NSString alloc] init];
        command = [[NSString alloc] init];
        timeout = [[NSString alloc] init];
        
        ConnectStatus = 0;
        
        
        Result = [[NSString alloc] init];
        AbsolutePath = [[NSString alloc] init];
        SN = [[NSString alloc] init];
        NameOfPDCA = [[NSString alloc] init];
        ResultStatus = YES;
        SourceDirectory = [[NSString alloc] init];

    }
    return self;
}


-(BOOL) initInformation
{
    stationName  = [self readPlist:@"StationName"];
    appVersion   = [self readPlist:@"AppVersion"];
    appName      = [self readPlist:@"AppName"];
    readPath     = [self readPlist:@"PathOfReadFile"];
    savePath     = [self readPlist:@"PathOfSaveFile"];
    backupsPath  = [self readPlist:@"PathOfBackupsFile"];
    reportPath   = [self readPlist:@"PathOfReportFile"];
    mountCommand = [self readPlist:@"CommandOfMount"];
    IPAddress    = [self readPlist:@"IPAddress"];
    documentPath = [self readPlist:@"PathOfDocument"];
    SourceDirectory = [self readPlist:@"SourceDirectory"];
    
    return TRUE;
}

- (NSString *)readPlist:(NSString *)key
{
    NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
    NSString * information = [dataDic objectForKey:key];
    return information;
}

- (void)createFileFolder
{
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:readPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fm createDirectoryAtPath:savePath  withIntermediateDirectories:YES attributes:nil error:nil];
    [fm createDirectoryAtPath:backupsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fm createDirectoryAtPath:reportPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fm createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
}


- (void)monitorFileFolder
{
    while(1)
    {
        //Please do not remove the delay.
        usleep(100000);
        @autoreleasepool
        {
            NSFileManager * fm = [[NSFileManager alloc] init];
            fm = [NSFileManager defaultManager];
            NSDirectoryEnumerator *dirEnum = [[NSDirectoryEnumerator alloc] init];
            dirEnum = [fm enumeratorAtPath:readPath];
            NSInteger snLength = -1;
    
            //Log files process
            for(fileName in dirEnum)
            {
                snLength = [[self regex:@"([[A-Z]\\d]*)" content:fileName] length];
                if([[[fileName componentsSeparatedByString:@"."] lastObject] isEqualToString:@"txt"] && snLength == 17)
                {
                    usleep(10000000);
                    if([self readFile] == -1)
                    {
                        [self writeToDocument:@"Read buffer" decription:@"buffer is nil!"];
                        continue;
                    }
                    
                    [self backupsFile];
                    [self praseFile];
                    [self createReportFolder];
                    [self getPDCAHandle];
                    [self insertAttribute];
                    [self insertTestItemAndResult];
                    [self addAndCommitPdca];
                    [self deleteFileAtReadPath];
                    [self showToTableView];
                }
            }
        }
    }
}



- (NSUInteger) readFile
{
    buffer = [NSString stringWithContentsOfFile:[readPath stringByAppendingString:fileName] encoding:NSASCIIStringEncoding error:nil];
    
    if([buffer isEqualToString:@""])
    {
        return -1;
    }
    else
    {
        return 1;
    }
}


- (void) backupsFile
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [self creatDatePath:backupsPath];
    [fm copyItemAtPath:[readPath stringByAppendingPathComponent:fileName] toPath:[backupsPath stringByAppendingFormat:@"%@/%@",datePath,fileName] error:nil];
    [self writeToDocument:@"Backup file" decription:@"backups file is success!"];
}


- (void)deleteFileAtReadPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[readPath stringByAppendingString:fileName] error:nil];
    [fm removeItemAtPath:[[readPath stringByAppendingString:[[fileName componentsSeparatedByString:@"."] firstObject]] stringByAppendingString:@".zip"] error:nil];
}


- (void) praseFile
{
    sn = [[fileName componentsSeparatedByString:@"_"] firstObject];
    dateAndtime = [[[[[fileName componentsSeparatedByString:@"_"] objectAtIndex:1] \
                     stringByAppendingString:[[fileName componentsSeparatedByString:@"_"] objectAtIndex:2]] \
                    componentsSeparatedByString:@"."] firstObject];
    
    if(NSNotFound != [buffer rangeOfString:@"FAIL"].location)
    {
        result = @"FAIL";
    }
    else
    {
        result = @"PASS";
    }
    
    NSString * path = [[NSString alloc] initWithString:[readPath stringByAppendingString:fileName]];
    
    AbsolutePath    = [[[path componentsSeparatedByString:@"."] firstObject] stringByAppendingString:@".zip"];
    NameOfPDCA      =[result stringByAppendingFormat:@"_%@",[[[[path componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject]];
    Result          = result;
    SN              = sn;
    
    if([Result isEqualToString:@"PASS"])
    {
        Result = @"1";
        ResultStatus = true;
    }
    else if([Result isEqualToString:@"FAIL"])
    {
        ResultStatus = false;
        Result = @"0";
    }
}


- (void)getPDCAHandle
{
    if(-1 == IP_getPdcaHandle(&UID))
    {
        [self writeToReport:@"\n---GetPDCAHandle---\n" decriptions:@"getPDCAHandle faid!"];
        [self writeToDocument:@"PDCA" decription:@"get PDCA handle is failed!"];
    }
    else
    {
        [self writeToReport:@"\n---GetPDCAHandle---\n" decriptions:@"getPDCAHandle success!"];
        [self writeToDocument:@"PDCA" decription:@"get PDCA handle is success!"];
    }
}


- (void)insertAttribute
{
    if(IP_insertAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, appVersion) < 0)
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute appversion failed!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute appversion failed!"];
    }
    else
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute appversion success!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute appversion success!"];
    }
    
    if(IP_insertAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWARENAME,@"charlieSW") < 0)
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute appName failed!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute appName failed!"];
    }
    else
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute appName success!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute appName success!"];
    }
    
    if (IP_insertAttribute(UID, IP_ATTRIBUTE_SERIALNUMBER, sn) < 0)
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute sn failed!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute sn failed!"];
    }
    else
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute sn success!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute sn success!"];
    }
}


- (void)insertTestItemAndResult
{
    [self writeToReport:@"\n---InsertTestItemAndResult---" decriptions:@"\n"];
    IP_insertTestItemAndResult(UID, @"RESULT", @"1", @"1", "NA", 0, Result, @"", ResultStatus);
}

- (void)addAndCommitPdca
{
    bool STATUS = NO;
    if([result isEqualToString:@"PASS"])
    {
        STATUS = YES;
    }
    else
    {
        STATUS = NO;
    }
    
    [self writeToReport:@"\n---AddAndCommitPDCA--" decriptions:@"\n"];
    [self compressFile];
    
    if(IP_addFile(UID, AbsolutePath, NameOfPDCA) == -1)
    {
        [self writeToReport:@"\nAddFile " decriptions:@"fail!\n"];
        [self writeToDocument:@"PDCA" decription:@"add file failed!"];
    }
    else
    {
        [self writeToReport:@"\nAddFile " decriptions:@"success!\n"];
        [self writeToDocument:@"PDCA" decription:@"add file sucess!"];
    }
    
    if(IP_commitData(UID, STATUS) == -1)
    {
        [self writeToReport:@"\ncommitData " decriptions:@"fail!\n"];
        [self writeToDocument:@"PDCA" decription:@"commit data failed!"];
        commitedPdcaStatus = @"FAIL";
    }
    else
    {
        [self writeToReport:@"\ncommitData " decriptions:@"success!\n"];
        [self writeToDocument:@"PDCA" decription:@"commit data success!"];
        commitedPdcaStatus = @"PASS";
    }
}


- (void)showToTableView
{
    [self.delegate showToTableView:fileName status:commitedPdcaStatus row:row];
    row++;
}


- (void)initDataForInsertTestItemAndResult:(NSUInteger)Count
{
    if([allResult[Count] integerValue] == 1)
    {
        isPass = true;
    }
    else
    {
        isPass = false;
    }
    
    if([allValue[Count] isEqualToString:@"Fail"]||[allValue[Count] isEqualToString:@"FAIL"]||[allValue[Count] isEqualToString:@"Failed"])
    {
        message = @"Not define error message!";
    }
    else
    {
        message = @"";
    }
    
    measurement = (char *)malloc(sizeof(strlen([allMeasurement[Count] cStringUsingEncoding:NSUTF8StringEncoding])+1));
    strcpy(measurement, [allMeasurement[Count] cStringUsingEncoding:NSUTF8StringEncoding]);
}


#pragma mark - ***Common factions***
- (void)compressFile
{
    NSString * cmdZip = [NSString stringWithFormat:@"/usr/bin/zip -rj %@ %@",AbsolutePath,[readPath stringByAppendingString:fileName]];
    system([cmdZip UTF8String]);
}


- (void)createSavePath
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [self creatDatePath:savePath];
    [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
    saveCSVFileNamePath = [NSString stringWithFormat:@"%@_%@_%@",status,sn,[dateFormatter stringFromDate:[NSDate date]]];
    [self createPath:[savePath stringByAppendingFormat:@"%@/%@",datePath,saveCSVFileNamePath]];
    saveCSVFileName = [saveCSVFileNamePath stringByAppendingFormat:@".csv"];
}

- (void)createPath:(NSString *)path
{
    NSFileManager *dir = [NSFileManager defaultManager];
    [dir createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}


- (void)creatDatePath:(NSString *)basepath
{
    NSFileManager *dir = [NSFileManager defaultManager];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    datePath = [dateFormatter stringFromDate:[NSDate date]];
    [dir createDirectoryAtPath:[basepath stringByAppendingString:datePath] withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)createFile:(NSString *)filename content:(NSString *)content
{
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filename contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
}


- (void)writeDataToFile:(NSString *)filename content:(NSString *)content
{
    NSFileHandle *fh = [[NSFileHandle alloc] init];
    NSData *stringData = [[NSData alloc] init];
    fh = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    [fh seekToEndOfFile];
    stringData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [fh writeData:stringData];
    [fh closeFile];
}

- (NSString *)regex:(NSString *)regex content:(NSString *)content
{
    NSRegularExpression * regexTmp = [[NSRegularExpression alloc] initWithPattern:regex options:0 error:0];
    NSTextCheckingResult * matchResTmp = [regexTmp firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
    NSRange rangeOfValue = [matchResTmp rangeAtIndex:1];
    NSString * RResult = [content substringWithRange:rangeOfValue];
    return RResult;
}

- (void)createReportFolder
{
    [self creatDatePath:reportPath];
    [self createFile:[reportPath stringByAppendingFormat:@"%@/%@.log",datePath,saveCSVFileNamePath] content:@"---Report---"];
}


- (void)writeToReport:(NSString *)act decriptions:(NSString *)decr
{
    [self writeDataToFile:[reportPath stringByAppendingFormat:@"%@/%@.log",datePath,saveCSVFileNamePath] content:[act stringByAppendingString:decr]];
}


- (void)createDocument
{
    NSString * date = [[NSString alloc] init];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    date = [dateFormatter stringFromDate:[NSDate date]];
    documentFileName = [documentPath stringByAppendingFormat:@"%@_Transformers.log",date];
    [self createFile:documentFileName content:@""];
}


- (void)writeToDocument:(NSString *)act decription:(NSString *)decr
{
    NSString * date = [[NSString alloc] init];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:ms"];
    date = [dateFormatter stringFromDate:[NSDate date]];
    [self writeDataToFile:documentFileName content:[NSString stringWithFormat:@"\n[%@]:---%@---\n%@\n",date,act,decr]];
}

#pragma mark - ***Monitor network***

- (BOOL) mountShareFolder
{
        NSString * Command = [[NSString alloc] init];
        Command = [mountCommand stringByAppendingFormat:@"%@%@ %@",IPAddress,SourceDirectory,readPath];
        system([Command UTF8String]);
        return YES;
}


#pragma mark ***Thread init***
- (BOOL)threadInit
{
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(monitorFileFolder) object:nil];
    thread.name = @"threadOfMonitorFileFolder";
    return YES;
}

- (void)threadCloed
{
    [self writeToDocument:@"Thread" decription:[NSString stringWithFormat:@"thread:%@  exit!",[NSThread currentThread].name]];
    [NSThread exit];
}

#pragma mark ***Run***
- (void)Run
{
    [self initInformation];
    [self createFileFolder];
    [self createDocument];
    [self writeToDocument:@"init information" decription:[NSString stringWithFormat:@"stationName:%@\nversion:%@",stationName,appVersion]];
    
    if([self mountShareFolder])
    {
        [self writeToDocument:@"mount share folder" decription:@"mount share folder is success!"];
    }
    else
    {
        [self writeToDocument:@"mount share folder" decription:@"mount share folder is Fail!"];
    }
    
    if([self threadInit])
    {
        [self writeToDocument:@"Thread init" decription:@"thread init is success!"];
    }
    else
    {
        [self writeToDocument:@"Thread init" decription:@"thread init is failed!"];
    }
    
    [thread start];
    [self writeToDocument:@"Monitor Folder" decription:@"start monitor folder"];
    [self writeToDocument:@"Monitor network status" decription:@"start monitor network status"];
}



@end
