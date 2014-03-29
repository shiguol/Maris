//
//  REMResponseSerializer.m
//  Maris
//
//  Created by Scott Petit on 3/29/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

#import "REMResponseSerializer.h"
#import <Mantle/Mantle.h>
#import "NSDictionary+Maris.h"

@interface REMResponseSerializer ()

@property (nonatomic, strong, readwrite) Class modelClass;
@property (nonatomic, copy, readwrite) NSString *keyPath;

@end

@implementation REMResponseSerializer

+ (instancetype)serializerWithModelClass:(Class)modelClass keyPath:(NSString *)keyPath
{
    return [[self alloc] initWithModelClass:modelClass keyPath:keyPath];
}

- (instancetype)initWithModelClass:(Class)modelClass keyPath:(NSString *)keyPath
{
    self = [[super class] serializer];
    if (self)
    {
        _modelClass = modelClass;
        _keyPath = keyPath;
    }
    return self;
}

#pragma mark - AFHTTPResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if (responseObject)
    {
        if ([self.keyPath length] && [responseObject isKindOfClass:[NSDictionary class]])
        {
            responseObject = [responseObject rem_objectForKeyPath:self.keyPath];
        }
        
        if (self.modelClass)
        {
            NSValueTransformer *valueTransformer = nil;
            
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                valueTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:self.modelClass];
            }
            else if ([responseObject isKindOfClass:[NSArray class]])
            {
                valueTransformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:self.modelClass];
            }
            
            responseObject = [valueTransformer transformedValue:responseObject];
        }
    }
    
    return responseObject;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        self.modelClass = [decoder decodeObjectForKey:NSStringFromSelector(@selector(modelClass))];
        self.keyPath = [decoder decodeObjectForKey:NSStringFromSelector(@selector(keyPath))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.modelClass forKey:NSStringFromSelector(@selector(modelClass))];
    [coder encodeObject:self.keyPath forKey:NSStringFromSelector(@selector(keyPath))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    REMResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.modelClass = self.modelClass;
    serializer.keyPath = [self.keyPath copy];
    
    return serializer;
}

@end