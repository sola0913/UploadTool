//
//  ViewController.m
//  UploadTool
//
//

#import "ViewController.h"
#import "InstantPuddingWrapper.h"

@interface ViewController ()<NSOutlineViewDataSource,NSOutlineViewDelegate>
{
    NSDateFormatter *timeFormat;
    NSString *filePath;
    NSFileHandle *fileHandle;
    bool startCheck;

   
}

@property (weak) IBOutlet NSTextField *serialNumber;
@property (weak) IBOutlet NSTextField *showNumber;
@property (weak) IBOutlet NSButton *finishBtn;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (copy) NSString *finalResult;
//@property(nonatomic,strong)NSArray *testItem;
@property(nonatomic,strong)NSDictionary *testItemDic;
//@property(nonatomic,strong)NSMutableDictionary *resultItem;
@property(nonatomic,strong)NSMutableArray *resultItem;

@end

@implementation ViewController


//=================================================================================

//NSString *logsPath = @"/Users/vault/";     //Setup when debug in lccation MacPro

NSString *logsPath = @"/vault/";       // Setup when running GH
//NSString *localLogsPath = @"/Users/gdlocal/LOG";       // Setup when running GH


- (id)init
{
    self = [super init];
    if (self)
    {
        //[self initPdcaHandle];
        
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
        SerialNumber = [[NSString alloc] init];
        
        

    }
    return self;
}

- (BOOL)getInformationFromPlist
{
    readPath     = [Common readPlist:PATHOFREADFILE];
    savePath     = [Common readPlist:PATHOFSAVEFILE];
    backupsPath  = [Common readPlist:PATHOFBACKUPSFILE];
    reportPath   = [Common readPlist:PATHOFREPORTFILE];
    documentPath = [Common readPlist:PATHOFDOCUMENTFILE];
    
    if(readPath == nil || savePath == nil || backupsPath == nil || reportPath == nil || documentPath == nil)
    {
        return FALSE;
    }
    
    return TRUE;
}


//=================================================================================

- (NSDictionary *)testItemDic
{
    
    if (_testItemDic == nil){
        _testItemDic=[[NSDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testItem" ofType:@"plist"]]];
    }
    //NSLog(@"print the testItemDic:%@",_testItemDic);
    return _testItemDic;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.serialNumber becomeFirstResponder];
   _resultItem = [NSMutableArray new];
//    //self.tableView.delegate = self;
    [self setSource:self.testItemDic];
    self.outlineView.delegate = self;
    self.outlineView.dataSource = self;
    dispatch_async(dispatch_get_main_queue(), ^{
          [self.outlineView expandItem:nil expandChildren:YES];
      });
    startCheck = NO;
    self.finalResult = @"";
    
//    [self TestAppContent];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}



- (void)writeDatatofile:(NSString *)string
{
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
//        [fileHandle closeFile];
    }
    else{
        NSString *header = @"Failure_Category,Module_Component_Locaiton,Failure_Symptom,Result\r\n";
        [header writeToFile:filePath
                 atomically:NO
                   encoding:NSStringEncodingConversionAllowLossy
                      error:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
}

- (void)Warning
{
    NSAlert *alertDefault = [[NSAlert alloc] init];
    [alertDefault setMessageText:@"SN Warnning:"];
    [alertDefault setInformativeText:@"Pls check the SN, length should be 10 or 12."];
    [alertDefault addButtonWithTitle:@"Ok"];
    [alertDefault runModal];
}

- (NSString *)creatTestDataPath:(NSString *)basePath
{
    NSFileManager *dir = [NSFileManager defaultManager];
     NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
     NSString *newLogFile = [[NSString alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd"];
     datePath = [dateFormatter stringFromDate:[NSDate date]];
    
     if(![dir createDirectoryAtPath:[basePath stringByAppendingString:datePath] withIntermediateDirectories:YES attributes:nil error:nil])
     {
         return @"";
     }
    
    newLogFile = [NSString stringWithFormat:@"%@%@%@",basePath,datePath,@"/"];
        
    return newLogFile;
    
}

- (NSDictionary *)getPlist:(NSString *)plistFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistFile ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

    return dict;
}

- (IBAction)finishScan:(NSTextField *)sender {
    NSString * sn = self.serialNumber.stringValue;
//    sn = self.serialNumber.stringValue;
    SerialNumber = sn;
    if ([sn isEqualToString:@""])
        return;
    NSInteger len = [sn length];
    NSLog(@"sn is %@, Length of sn is %ld",sn, len);
    if ((len == 10) || (len == 12))
    {
    [self.showNumber setStringValue:sn];
    [self.serialNumber setStringValue:@""];
    [self.serialNumber setEnabled:NO];
    timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH_mm_ss"];
    NSString *timeString = [timeFormat stringFromDate:[NSDate date]];
    NSString *fileName = [sn stringByAppendingString:[NSString stringWithFormat: @"_%@.csv",timeString]];
    NSString *newLogPath = [self creatTestDataPath:logsPath];
    filePath = [newLogPath stringByAppendingPathComponent:fileName];     //Logs path in GH station
    NSLog(@"## file path is %@ ##", filePath);
    [self writeDatatofile:@""];
    }
    else
        {
             [self Warning];
             [self.serialNumber setStringValue:@""];
             [self initPdcaHandle];      // GH
             [sender becomeFirstResponder];
             return;
         }

}


- (IBAction)finish:(NSButton *)sender {
    
        if([self.serialNumber isEnabled])
            return;
        [self.serialNumber setEnabled:YES];
        [self.showNumber setStringValue:@""];
        [self.serialNumber becomeFirstResponder];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        
//        NSLog(@"print the self.resultItem:%@",self.resultItem);
//        [self.resultItem enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            NSLog(@"print the key and value:%@,%@",key,obj);
//            [self writeDatatofile:[NSString stringWithFormat:@"%@,%@\r\n",key,obj]];
//        }];
//    //        [self writeDatatofile:[NSString stringWithFormat:@"%@,%@\r\n",[self.testItem objectAtIndex:i],result ? result:@"PASS"]];
        [self.testItemDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key1, id  _Nonnull obj1, BOOL * _Nonnull stop) {
                [obj1 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key2, id  _Nonnull obj2, BOOL * _Nonnull stop) {
                    if (self.resultItem.count > 0){
                        NSString *failname = [NSString stringWithFormat:@"%@_%@",key1,key2];
                        if ([self.resultItem containsObject:failname])
                        {
//                            [self writeDatatofile:[NSString stringWithFormat:@"%@,%@,%@,%@,HighLight\r\n",key,key1,key2,@"FAIL"]];
                            [self writeDatatofile:[NSString stringWithFormat:@"%@,%@,%@,%@,X\r\n",key,key1,key2,@"FAIL"]];
                            //NSLog(@"print the %@,%@,%@",key,key1,key2);
                          self.finalResult = @"FAIL";
                        }
                        else
                        {
                             [self writeDatatofile:[NSString stringWithFormat:@"%@,%@,%@,%@\r\n",key,key1,key2,@"PASS"]];
                            self.finalResult = [self.finalResult isEqualToString:@"FAIL"]?@"FAIL":@"PASS";
                        }
                  }
                    else{
                        [self writeDatatofile:[NSString stringWithFormat:@"%@,%@,%@,%@\r\n",key,key1,key2,@"PASS"]];
                          self.finalResult = [self.finalResult isEqualToString:@"FAIL"]?@"FAIL":@"PASS";
                    }
                }];
            }];
            
        }];
    
        NSLog(@" ### print the finalResult:%@ ### ",self.finalResult);
        NSLog(@" ### print the filePath:%@ ### ", filePath);
          
        //Add zipfile at Path : /vault:
//        NSString *newLogPath = [self creatTestDataPath:logsPath];
//        NSString *finalZipPath = [newLogPath substringToIndex:[newLogPath length]-1];
//        NSLog(@" ### print the newLogPath:%@ ### ", newLogPath);
//        NSLog(@" ### print the finalZipPath:%@ ### ", finalZipPath);
//        BOOL compressResult = [self compressFile:filePath path:finalZipPath];
//        NSLog(@" ### print the compressResult:%d ### ", compressResult);
//
        [self.resultItem removeAllObjects];
        [fileHandle closeFile];
//        filePath = @"";                   //Transfer to _PDCA_START_PHASE
        fileHandle = 0;
        //[self setSource:self.testItemDic];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self setSource:self.testItemDic];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];
        });
    
        Result = [[NSString alloc] initWithString:_finalResult];
        NSLog(@" ### Result is %@, finalResutl is %@ ###",result, _finalResult);

    
    //upload pdca
    OVitem *item = [[OVitem alloc] init];
    
    [self getPDCAHandle];
    [self _insertAttribute];
    //[self _PDCA_START_PHASE];
    [self _PDCA_END_PHASE];

//    if (UID != nil) {
//        IP_reply_destroy(UID);
//        UID = nil;
//        NSLog(@"### Clear UID have been executed. ###");
//    }
    
    self.finalResult = @"";
    
    NSLog(@"### Finish have been executed. ###");
    
    return;
}

#pragma mark - <NSTableViewDelegate,NSTableViewDataSource>

//- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
//{
//    return [self.testItem count];
//}

//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    if(row >= [self.testItem count])
//        return nil;
////    NSDictionary* dic = [self.testItem objectAtIndex:row];
////    NSString *value = [dic objectForKey:[tableColumn title]];
//    if([[tableColumn title] isEqualToString:@"Test Item"])
//    {
//        NSString *value = [self.testItem objectAtIndex:row];
//        return value ?:nil;
//    }
//    if([[tableColumn title] isEqualToString:@"Result"])
//    {
//        NSButton *cell = [[NSButton alloc] init];
//        return cell;
//    }
//    return nil;
////      return self.testItem[row];
//}


- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        return [_rootTreeNode childNodes];
    } else {
        return [item childNodes];
    }
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
    NSArray *children = [self childrenForItem:item];
    return [children count];
    
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    //NSLog(@"print the start1");
    OVitem *_item =   [item representedObject];
    NSString *identify=[tableColumn title];
    id obj=nil;
    if ([identify isEqualToString:@"Key"]) {
//    if ([identify isEqualToString:@"Category"]) {
        obj =[_item oKey];
    }
    else if ([identify isEqualToString:@"Value"]){
//    else if ([identify isEqualToString:@"Result"]){
        obj =[_item oValue];
        
        if ([obj isEqualToString:@"YES"]) {
            NSNumber *bValue=[NSNumber numberWithBool:YES];
            obj=bValue;
        }else if ([obj isEqualToString:@"NO"]){
            NSNumber *bValue=[NSNumber numberWithBool:NO];
            obj=bValue;
        }
        
        
    }
    return obj;
    
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    //NSLog(@"print the start2");
    NSCell *cell=[tableColumn dataCell];
    OVitem *_item =   [item representedObject];
    NSString *identify=[tableColumn title];
    id obj=nil;
    if ([identify isEqualToString:@"Key"]) {
        obj =[_item oKey];
        
    }
    else if ([identify isEqualToString:@"Value"]){
        obj =[_item oValue];
        if ([obj isEqualToString:@"YES"] || [obj isEqualToString:@"NO"]) {
            NSButtonCell *btnCell= [[NSButtonCell alloc] init];
            [btnCell setButtonType:NSSwitchButton];
            [btnCell setTitle:@""];
            cell = btnCell;
            
        }
        
    }
    return cell;
    
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    OVitem *_item = [item representedObject];
    NSArray *children = [self childrenForItem:item];
    if (startCheck == YES)
    {
        if ([_resultItem containsObject:[NSString stringWithFormat:@"%@_%@",_item.oKey,[_item.childs objectAtIndex:index]]]){
            [_resultItem removeObject:[NSString stringWithFormat:@"%@_%@",_item.oKey,[_item.childs objectAtIndex:index]]];
            //NSLog(@"print the remove key:%@",_item.oKey);
        }
        else{
            [_resultItem addObject:[NSString stringWithFormat:@"%@_%@",_item.oKey,[_item.childs objectAtIndex:index]]];
            //NSLog(@"print the add key:%@",_item.oKey);
        }
        startCheck = NO;
    }
    
    return [children objectAtIndex:index];
    
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    OVitem *_item =   [item representedObject];
    
    return  ! [_item isLeaf];
    
}
-(void)setSource:(NSDictionary *)dict;
{
    OVitem *item=[OVitem itemWithKey:@"Root" AndValue:@"Root"];
    [item setIsLeaf:NO];
    [item childsFromDictionary:dict];
    [item setDataType:OVDictionaryType];
    _rootTreeNode=[NSTreeNode treeNodeWithRepresentedObject:item];
    [[_rootTreeNode mutableChildNodes] addObjectsFromArray:item.childNodes];
    
}
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    startCheck = YES;
    OVitem *_item =   [item representedObject];
    if (_item.isLeaf == NO || [[tableColumn title] isEqualToString:@"Key"] ) {
        [_item setOKey:object];
        return;
    }
    if ([[object className] isEqualToString:@"__NSCFBoolean"]) {
        
        if ([object boolValue] == YES) {
            [_item setOValue:@"YES"];
            
        }else{
            [_item setOValue:@"NO"];
            
        }
        
    }else{
        [_item setOValue:object];
    }
    
     //NSLog(@"Object:%@,Item:%@",object,item);
}


//===================================================================================================

- (void)Run
{
    
}

- (NSString *)getSWVersion:(NSString *)appRelatedKey
{
    NSDictionary *SWVerisonDic = [self getPlist:@"baseInfo"];
    NSString *baseInfoValue = [SWVerisonDic valueForKey:appRelatedKey];
    
    return baseInfoValue;
}

- (void)TestAppContent
{
    NSString *SWVersion = [self getSWVersion:@"SWVersion"];
    NSString *SWName = [self getSWVersion:@"SWName"];
    NSLog(@"### SWVersion is %@,SWName is %@ ###",SWVersion,SWName);
}

- (BOOL)compressFile:(NSString *)file path:(NSString *)logsAbsolutePath
{
    pid_t system_sh_status;
    NSString * cmdZip = [NSString stringWithFormat:@"/usr/bin/zip -rj %@ %@",logsAbsolutePath,file];
    if(cmdZip == NULL)
    {
        return FALSE;
    }
    system_sh_status = system([cmdZip UTF8String]);
    
    if(-1 == system_sh_status)
    {
        return FALSE;
    }
    else
    {
        if(WIFEXITED(system_sh_status))
        {
            if(0 == WEXITSTATUS(system_sh_status))
            {
                return TRUE;
            }
            else
            {
                return FALSE;
            }
        }
        else
        {
            return FALSE;
        }
    }
}

- (BOOL)deleteFile:(NSString *)logsAbsolutePathFile
{
    pid_t system_sh_status;
    NSString * cmdZip = [NSString stringWithFormat:@"rm -rf %@",logsAbsolutePathFile];
    if(cmdZip == NULL)
    {
        return FALSE;
    }
    system_sh_status = system([cmdZip UTF8String]);
    
    if(-1 == system_sh_status)
    {
        return FALSE;
    }
    else
    {
        if(WIFEXITED(system_sh_status))
        {
            if(0 == WEXITSTATUS(system_sh_status))
            {
                return TRUE;
            }
            else
            {
                return FALSE;
            }
        }
        else
        {
            return FALSE;
        }
    }
}

//===================================================================================================

- (void)initPdcaHandle
{
    //#if PDCA_ON
    int ret = IP_getPdcaHandle(&UID);
    if(ret == -1){
        self->UID = nil;
    }
    //#endif
}

- (void)_PDCA_START_PHASE
{
    int success;
    // upload to PDCA
    // TODO: sw_version and name
//================================== Add SWVersion and SWName ============================================
    NSString *SWVersion = [self getSWVersion:@"SWVersion"];
    NSString *SWName = [self getSWVersion:@"SWName"];
    NSLog(@"### SWVersion is %@,SWName is %@ ###",SWVersion,SWName);
    

//    2020-12-27 17:55:07.451400+0800 UploadTool[79907:6441250] ### SWVersion is 1.0,SWName is UploadTool ###
    
//================================== Add SWVersion and SWName ============================================
    
    success = IP_insertAttribute(self->UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, SWVersion);
    if(success < 0){
        self->UID = nil;
    }
    success = IP_insertAttribute(self->UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, SWName);
    if(success < 0){
        self->UID = nil;
    }
    
    NSLog(@"### PDCA_START_PHASE have been executed. ###");
}

- (void)_PDCA_END_PHASE
{
    BOOL isAllPassing ;
    int success;
    NSString *result = @"";
    if([_finalResult isEqualToString:@"PASS"])
    {
        isAllPassing = IP_PASS;
        result = @"1";
        
    }
    else
    {
        isAllPassing = IP_FAIL;
        result = @"0";
    }
    success = IP_insertTestItemAndResult(UID, @"RESULT", @"1", @"1", "NA", 0, result, @"", isAllPassing);
    if(success < 0)
    {
        
        NSLog(@"IP_insertTestItemAndResult: ret = %d", success);
    }
    else
    {
        NSLog(@"IP_insertTestItemAndResult: PASS");
    }
    

//================================== Only add Zip file under /vault/ ============================================
//    NSString *newLogPath = [self creatTestDataPath:logsPath];
//    NSString *finalZipPath = [newLogPath substringToIndex:[newLogPath length]-1];
//    NSLog(@" ### print the newLogPath:%@ ### ", newLogPath);
//    NSLog(@" ### print the finalZipPath:%@ ### ", finalZipPath);
//    NSLog(@" ### print the filePath:%@ ### ", filePath);
//    BOOL compressResult = [self compressFile:filePath path:finalZipPath];
//    NSLog(@" ### print the compressResult:%d ### ", compressResult);
//    NSLog(@" ### print the datePath:%@ ### ", datePath);
//    zipFileName = [datePath stringByAppendingFormat:@".zip"];
//    zipFilePath = logsPath;
//    NSLog(@" ### print the zipFileName:%@ ### ", zipFileName);
//    NSLog(@" ### print the zipFilePath:%@ ### ", zipFilePath);

//================================== Only add Zip file under /vault/ ============================================
    
//   ==============Add standard format zip file as fileNameDescript under local MacPro /Users/vault/, will chagne to /vault/ after GH ==========
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HHmmss"];
    NSString *timeString = [timeFormat stringFromDate:[NSDate date]];
    
    NSString *fileNameDescrip = [NSString stringWithFormat:@"%@_%@_%@_%@", _finalResult, SerialNumber, dateString,timeString];
    NSLog(@" ### print the fileNameDescrip:%@ ### ", fileNameDescrip);
    
    NSFileManager *dir = [NSFileManager defaultManager];
    
    [dir createDirectoryAtPath:[logsPath stringByAppendingString:fileNameDescrip] withIntermediateDirectories:YES attributes:nil error:nil];
    NSString * newStandFormatDescrip = [NSString stringWithFormat:@"%@%@",logsPath,fileNameDescrip];
 
    [self compressFile:filePath path:newStandFormatDescrip];
    
    zipFilePath = [newStandFormatDescrip stringByAppendingFormat:@".zip"];
    NSLog(@" ### print the newStandFormatDescrip:%@ ### ", newStandFormatDescrip);
    zipFileName = [fileNameDescrip stringByAppendingFormat:@".zip"];
    NSLog(@" ### zipFilePath is %@, zipFileName is %@ ### ", zipFilePath, zipFileName);
    [self deleteFile:newStandFormatDescrip];
//   ==============Add standard format zip file as fileNameDescript under local MacPro /Users/vault/, will chagne to /vault/ after GH ==========
    
//2020-12-27 20:43:57.168399+0800 UploadTool[82701:6554729] ## file path is /Users/vault/2020-12-27/HT2WV4FHJN_20_43_57.csv ##
//2020-12-27 20:43:59.896828+0800 UploadTool[82701:6554729]  ### print the finalResult:FAIL ###
//2020-12-27 20:43:59.896897+0800 UploadTool[82701:6554729]  ### print the filePath:/Users/vault/2020-12-27/HT2WV4FHJN_20_43_57.csv ###
//2020-12-27 20:43:59.897051+0800 UploadTool[82701:6554729]  ### Result is (null), finalResutl is FAIL ###
//2020-12-27 20:43:59.897401+0800 UploadTool[82701:6554729] ### SWName is UploadTool,appVersion is 1.0,SerialNumber is HT2WV4FHJN ###
//2020-12-27 20:43:59.897975+0800 UploadTool[82701:6554729] insertAttribute have been executed.
//2020-12-27 20:43:59.898285+0800 UploadTool[82701:6554729] ### SWVersion is 1.0,SWName is UploadTool ###
//2020-12-27 20:43:59.898337+0800 UploadTool[82701:6554729] IP_insertTestItemAndResult: ret = -1
//2020-12-27 20:43:59.898651+0800 UploadTool[82701:6554729]  ### print the fileNameDescrip:FAIL_HT2WV4FHJN_20201227_204359 ###
//  adding: HT2WV4FHJN_20_43_57.csv (deflated 70%)
//2020-12-27 20:43:59.908066+0800 UploadTool[82701:6554729]  ### print the newStandFormatDescrip:/Users/vault/FAIL_HT2WV4FHJN_20201227_204359 ###
//2020-12-27 20:43:59.908159+0800 UploadTool[82701:6554729]  ### print the zipFilePath:/Users/vault/FAIL_HT2WV4FHJN_20201227_204359.zip ###
//2020-12-27 20:43:59.908219+0800 UploadTool[82701:6554729]  ### print the zipFileName:FAIL_HT2WV4FHJN_20201227_204359.zip ###
    
    filePath = @"";
    
//================================== Add Zip file ============================================
    //zipPath:          /vault/Report/CONNECTIVITY-TEST2/2015-09-17/FAIL_F9FPW6D8FLMJ_20150917_092501.zip
    //fileNameDescrip:  FAIL_F9FPW6D8FLMJ_20150917_092501
    
    success = IP_addFile(UID, zipFilePath, zipFileName);
    if(success < 0)
    {
        
        NSLog(@"IP_addFile: ret = %d", success);
    }
    else
    {
        NSLog(@"IP_addFile: PASS");
    }
    
    if (([SerialNumber length] == 10) || [SerialNumber length] == 12) {
        //allPass:
//        NSString *cmdZip = @"open /Users/gdlocal/Desktop/";
//        system([cmdZip UTF8String]);
        success = IP_commitData(UID, isAllPassing);
        if(success < 0)
        {

            NSLog(@"IP_commitData: ret = %d", success);
        }
        else
        {
            NSLog(@"IP_commitData: PASS");
        }
    } else {
        IP_fail_releaseUUT(UID);
    }
    
    NSLog(@"### PDCA_END_PHASE have been executed. ###");
}


//- (BOOL) insertAttribute
//{
//    NSString *SWVersion = [self getSWVersion:@"SWVersion"];
//    NSString *SWName = [self getSWVersion:@"SWName"];
//
//    if(IP_insertAttribute(UID, IP_ATTRIBUTE_SERIALNUMBER, SerialNumber) < 0)
//    {
//        return FALSE;
//    }
//
//    if(IP_insertAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWARENAME,SWName) < 0)
//    {
//        return FALSE;
//    }
//
//    if(IP_insertAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, SWVersion) < 0)
//    {
//        return FALSE;
//    }
//
//    return TRUE;
//}


- (void)_insertAttribute
{
    
    NSString *SWName = [self getSWVersion:@"SWName"];
    NSString *appVersion = [self getSWVersion:@"appVersion"];
    NSLog(@"### SWName is %@,appVersion is %@,SerialNumber is %@ ###", SWName, appVersion,SerialNumber);
    
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
    
    if(IP_insertAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWARENAME,SWName) < 0)
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute appName failed!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute appName failed!"];
    }
    else
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute appName success!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute appName success!"];
    }
    
    if (IP_insertAttribute(UID, IP_ATTRIBUTE_SERIALNUMBER, SerialNumber) < 0)
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute sn failed!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute sn failed!"];
    }
    else
    {
        [self writeToReport:@"\n---InsertAttribute---\n" decriptions:@"InsertAttribute sn success!\n"];
        [self writeToDocument:@"PDCA" decription:@"InsertAttribute sn success!"];
    }
    
    NSLog(@"### insertAttribute have been executed.###");
}


- (void)writeToReport:(NSString *)act decriptions:(NSString *)decr
{
    [self writeDataToFile:[reportPath stringByAppendingFormat:@"%@/%@.log",datePath,saveCSVFileNamePath] content:[act stringByAppendingString:decr]];
}


- (void)writeToDocument:(NSString *)act decription:(NSString *)decr
{
    NSString * date = [[NSString alloc] init];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:ms"];
    date = [dateFormatter stringFromDate:[NSDate date]];
    [self writeDataToFile:documentFileName content:[NSString stringWithFormat:@"\n[%@]:---%@---\n%@\n",date,act,decr]];
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

- (void)getPDCAHandle
{
    IP_reply_destroy(UID);
    self->UID = nil;
    
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


@end





