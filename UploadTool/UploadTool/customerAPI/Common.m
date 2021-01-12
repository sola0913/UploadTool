//
//  Common.m
//  UploadTool
//
//

#import "Common.h"

@implementation Common

+ (NSString *)readPlist:(NSString *)key
{
    NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"baseInfo" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
    NSString * information = [dataDic objectForKey:key];
    return information;
}

+ (BOOL)createPath:(NSString *)path
{
    NSFileManager *dir = [NSFileManager defaultManager];
    if(![dir createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return FALSE;
    }
    
    return TRUE;
}


+ (BOOL)createFile:(NSString *)pathAndFileName content:(NSString *)content
{
    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm createFileAtPath:pathAndFileName contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil])
    {
        return FALSE;
    }
    
    return TRUE;
}

+ (NSString *)creatDatePath:(NSString *)basePath
{
    NSFileManager *dir = [NSFileManager defaultManager];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSString * datePath = [[NSString alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    datePath = [dateFormatter stringFromDate:[NSDate date]];
    
    if(![dir createDirectoryAtPath:[basePath stringByAppendingString:datePath] withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return @"";
    }

    return datePath;
}

+ (BOOL)writeDataToFile:(NSString *)filename content:(NSString *)content
{
    NSFileHandle *fh = [[NSFileHandle alloc] init];
    NSData *stringData = [[NSData alloc] init];
    fh = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    
    if(fh == nil)
    {
        return FALSE;
    }
    
    [fh seekToEndOfFile];
    stringData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [fh writeData:stringData];
    [fh closeFile];
    
    return TRUE;
}


+ (NSString *)readFileDataToBuffer:(NSString *)path
{
    NSString * buffer = [[NSString alloc] init];
    buffer = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    if(buffer == nil)
    {
        return @"";
    }
    
    return buffer;
}


+ (NSString *)regex:(NSString *)regex content:(NSString *)content
{
    NSRegularExpression * regexTmp = [[NSRegularExpression alloc] initWithPattern:regex options:0 error:0];
    NSTextCheckingResult * matchResTmp = [regexTmp firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
    NSRange rangeOfValue = [matchResTmp rangeAtIndex:1];
    NSString * result = [content substringWithRange:rangeOfValue];
    return result;
}


@end
