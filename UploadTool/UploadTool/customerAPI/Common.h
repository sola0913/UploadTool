//
//  Common.h
//  UploadTool
//
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+ (BOOL)createPath:(NSString *)path;
+ (BOOL)createFile:(NSString *)filename content:(NSString *)content;
+ (BOOL)writeDataToFile:(NSString *)filename content:(NSString *)content;

+ (NSString *)readPlist:(NSString *)key;
+ (NSString *)creatDatePath:(NSString *)basePath;
+ (NSString *)readFileDataToBuffer:(NSString *)path;
+ (NSString *)regex:(NSString *)regex content:(NSString *)content;


@end
