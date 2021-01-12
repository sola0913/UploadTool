//
//  File.m
//  UploadTool
//
//

#import "File.h"

@implementation File

- (id)init
{
    self = [super init];
    
    if (self)
    {
        buffer              = [[NSString alloc] init];
        sn                  = [[NSString alloc] init];
        result              = [[NSString alloc] init];
        readPath            = [[NSString alloc] init];
        savePath            = [[NSString alloc] init];
        backupsPath         = [[NSString alloc] init];
        reportPath          = [[NSString alloc] init];
        documentPath        = [[NSString alloc] init];
        backupsDatePath     = [[NSString alloc] init];
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

- (BOOL)createFileFolder
{
    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm createDirectoryAtPath:readPath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return FALSE;
    }
    
    if(![fm createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return FALSE;
    }
    
    if(![fm createDirectoryAtPath:backupsPath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return FALSE;
    }
    
    if(![fm createDirectoryAtPath:reportPath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return FALSE;
    }
    
    if(![fm createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)backupsFile:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    backupsDatePath = [Common creatDatePath:backupsPath];
    
    if(![fm copyItemAtPath:[readPath stringByAppendingPathComponent:fileName] toPath:[backupsPath stringByAppendingFormat:@"%@/%@",backupsDatePath,fileName] error:nil])
    {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)deleteFileAtReadPath:(NSString *)fileName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm removeItemAtPath:[readPath stringByAppendingString:fileName] error:nil])
    {
        return FALSE;
    }
    
    if(![fm removeItemAtPath:[[readPath stringByAppendingString:[[fileName componentsSeparatedByString:@"."] firstObject]] stringByAppendingString:@".zip"] error:nil])
    {
        return FALSE;
    }
    
    return TRUE;
}


- (BOOL)readFile:(NSString *)fileName
{
    buffer = [NSString stringWithContentsOfFile:[readPath stringByAppendingString:fileName] encoding:NSASCIIStringEncoding error:nil];
    
    if([buffer isEqualToString:@""] || buffer == nil)
    {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)praseFile:(NSString *)fileName
{
    sn = [[fileName componentsSeparatedByString:@"_"] firstObject];
    dateAndtime = [[[[[fileName componentsSeparatedByString:@"_"] objectAtIndex:1] stringByAppendingString:[[fileName componentsSeparatedByString:@"_"] objectAtIndex:2]] componentsSeparatedByString:@"."] firstObject];
    if(NSNotFound != [buffer rangeOfString:@"FAIL"].location)
    {
        result = @"FAIL";
    }
    else
    {
        result = @"PASS";
    }
    
    return TRUE;
}



@end
