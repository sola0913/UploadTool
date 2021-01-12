//
//  OVitem.m
//  UploadTool
//
//

#import "OVitem.h"


@implementation OVitem
@synthesize isLeaf=_isLeaf;
@synthesize childs=_childs;
-(id)init{
    self = [super init];
    if(self != nil){
        _oKey=@"Key";
        _oValue=@"Value";
        _isLeaf=YES;
        _childs=[NSMutableArray array];
        _childNodes=[NSMutableArray array];
        
    }
    return self;
}

+(OVitem *)itemWithKey:(NSString *)key AndValue:(NSString *)value
{
    OVitem *item=[[OVitem alloc] init];
    [item setOKey:key];
    [item setOValue:value];
    [item setDataType:OVStringType];
    return item;
}

-(void)addChild:(OVitem*)child;
{
    [_childs addObject:child];
    NSTreeNode *node=[NSTreeNode treeNodeWithRepresentedObject:child];
    [_childNodes addObject:node];
    
}

-(void)removeChildAtIndex:(NSUInteger)idx;
{
    [_childs removeObjectAtIndex:idx];
    [_childNodes removeObjectAtIndex:idx];
}

-(void)childsFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pArray=[[NSMutableArray alloc]init];
    NSArray* pKeys=[dict allKeys];
    for (int i=0; i<dict.count; i++) {
        NSString* key=pKeys[i];
        NSString* obj=dict[key];
        [pArray addObject:@{key:obj}];
    }
//    for (int i=0; i<pArray.count; i++) {
//        NSDictionary *temp=nil;
//        for (int j=i+1; j<pArray.count; j++) {
//            NSArray* keys0=[pArray[i] allKeys];
//            NSArray* keys1=[pArray[j] allKeys];
//            NSString* key0=keys0[0];
//            NSString* key1=keys1[0];
//            if ([[key0 lowercaseString] compare:[key1 lowercaseString]]==NSOrderedDescending) {
//                temp=pArray[i];
//                pArray[i]=pArray[j];
//                pArray[j]=temp;
//            }
//        }
//    }
    for (int i=0; i<pArray.count; i++) {
        [pArray[i] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                OVitem *item=[OVitem itemWithKey:key AndValue:obj];
                [item setIsLeaf:YES];
                [item setChilds:nil];
                [item setDataType:OVStringType];
                [self addChild:item];
                [self->_iteminfo addObject:obj];
            }
            
            else if ([obj isKindOfClass:[NSDictionary class]]) {
                OVitem *item=[OVitem itemWithKey:key AndValue:@""];
                [item setIsLeaf:NO];
                [item childsFromDictionary:obj];
                [item setDataType:OVDictionaryType ];
                
                [self->_childs addObject:item];
                NSTreeNode *node=[NSTreeNode treeNodeWithRepresentedObject:item];
                [self->_childNodes addObject:node];
                [[node mutableChildNodes] addObjectsFromArray:item.childNodes];
            }
            else if ([obj isKindOfClass:[NSArray class]]) {
                OVitem *item=[OVitem itemWithKey:key AndValue:@""];
                [item setIsLeaf:NO];
                [item childsFromArray:obj];
                [item setDataType:OVArrayType ];
                
                [self->_childs addObject:item];
                
                NSTreeNode *node=[NSTreeNode treeNodeWithRepresentedObject:item];
                [self->_childNodes addObject:node];
                [[node mutableChildNodes] addObjectsFromArray:item.childNodes];
                
            }
        }];
        
    }
     //NSLog(@"Childs:%@",_childs);
    
}

-(void)childsFromArray:(NSArray *)arr;
{
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            OVitem *item=[OVitem itemWithKey:obj AndValue:@""];
            [item setIsLeaf:NO];
            [item childsFromDictionary:obj];
            [item setDataType:OVDictionaryType ];
            
            [self->_childs addObject:item];
            
            NSTreeNode *node=[NSTreeNode treeNodeWithRepresentedObject:item];
            [self->_childNodes addObject:node];
            [[node mutableChildNodes] addObjectsFromArray:item.childNodes];
            
        }
        if ([obj isKindOfClass:[NSString class]]) {
            OVitem *item=[OVitem itemWithKey:[NSString stringWithFormat:@"Item %lu",idx] AndValue:obj];
            [item setIsLeaf:YES];
            [item setChilds:nil];
            [item setDataType:OVStringType];
            [self->_childs addObject:item];
            
            NSTreeNode *node=[NSTreeNode treeNodeWithRepresentedObject:item];
            [self->_childNodes addObject:node];
        }
        
    }];
}
-(id)childsToObject;
{
    id obj=nil;
    if (self.dataType == OVDictionaryType) {
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:10];
        [_childs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            OVitem *item=obj;
            if (item.isLeaf ==YES) {
                [dict setObject:item.oValue forKey:item.oKey];
            }else{
                [dict setObject:[item childsToObject] forKey:item.oKey];
            }
        }];
        
        obj = dict;
    }
    
    if (self.dataType == OVArrayType) {
        NSMutableArray *arr=[NSMutableArray arrayWithCapacity:10];
        [_childs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            OVitem *item=obj;
            if (item.isLeaf ==YES) {
                [arr addObject:item.oValue];
            }else{
                [arr addObject:[item childsToObject]];
            }
        }];
        obj=arr;
        
    }
    return obj;
}
-(NSString *)description{
    //NSLog(@"Key:%@ IsLeaf:%i,Childs:%@",_key,isLeaf,_childs);
    return _oKey;
}


@end
