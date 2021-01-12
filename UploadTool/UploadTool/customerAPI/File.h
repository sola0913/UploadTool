//
//  File.h
//  UploadTool
//
//


#import <Foundation/Foundation.h>
#import "Common.h"

#define PATHOFREADFILE      @"PathOfReadFile"
#define PATHOFSAVEFILE      @"PathOfSaveFile"
#define PATHOFBACKUPSFILE   @"PathOfBackupsFile"
#define PATHOFREPORTFILE    @"PathOfReportFile"
#define PATHOFDOCUMENTFILE  @"PathOfDocument"

@interface File : NSObject
{
@public
    NSString * buffer;
     NSString * sn;
     NSString * result;
     NSString * dateAndtime;
     
     NSString * readPath;
     NSString * savePath;
     NSString * backupsPath;
     NSString * reportPath;
     NSString * documentPath;
     NSString * backupsDatePath;
}

- (BOOL)getInformationFromPlist;
- (BOOL)createFileFolder;
- (BOOL)backupsFile:(NSString *)fileName;
- (BOOL)deleteFileAtReadPath:(NSString *)fileName;
- (BOOL)readFile:(NSString *)fileName;
- (BOOL)praseFile:(NSString *)fileName;

@end
