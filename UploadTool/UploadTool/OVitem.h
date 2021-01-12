//
//  OVitem.h
//  UploadTool
//
//

#import <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

typedef enum _DataType{
    OVStringType=0,
    OVDictionaryType=1,
    OVArrayType=2
}OVDataType;

@interface OVitem : NSObject
{
    
}
@property(copy)NSString *oKey;
@property(copy)NSString *oValue;
@property(assign)BOOL isLeaf;
@property(retain )NSMutableArray *childs;
@property(retain )NSMutableArray *childNodes;
@property(assign)OVDataType dataType;
@property(retain )NSMutableArray *iteminfo;
+(OVitem *)itemWithKey:(NSString *)key AndValue:(NSString *)value;
-(void)childsFromDictionary:(NSDictionary *)dict;
-(void)childsFromArray:(NSArray *)arr;
-(id)childsToObject;
-(void)addChild:(OVitem*)child;
-(void)removeChildAtIndex:(NSUInteger)idx;


@end
