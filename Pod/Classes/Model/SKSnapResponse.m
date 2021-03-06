//
//  SKSnapResponse.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/29/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnapResponse.h"


@implementation SKSentSnap

- (id)initWithDictionary:(NSDictionary *)json sender:(NSString *)sender {
    self = [super initWithDictionary:json];
    if (self) {
        _sender     = sender;
        _identifier = json[@"id"];
        _timestamp  = [NSDate dateWithTimeIntervalSince1970:[json[@"timestamp"] doubleValue]/1000];
    }
    
    return self;
}

/// Do not use

- (id)initWithDictionary:(NSDictionary *)json { [NSException raise:NSInternalInconsistencyException format:@"Use -initWithDictionary:sender:"]; return nil; }

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ sender=%@, id=%@, ts=%lu>",
            NSStringFromClass(self.class), self.sender, self.identifier, (unsigned long)self.timestamp.timeIntervalSince1970];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"identifier": @"id",
             @"timestamp": @"timestamp"};
}

MTLTransformPropertyDate(timestamp)

@end


@implementation SKSnapResponse

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ success=%d> Snaps:\n%@",
            NSStringFromClass(self.class), self.success, self.sentSnaps];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"success": @"snap_response.success",
             @"sentSnaps": @"snap_response.snaps"};
}

+ (NSValueTransformer *)sentSnapsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *snaps, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSString *sender in snaps.allKeys)
            [temp addObject:[[SKSentSnap alloc] initWithDictionary:snaps[sender] sender:sender]];
        return temp.copy;
    } reverseBlock:^id(NSArray *snaps, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        for (SKSentSnap *snap in snaps)
            json[snap.sender] = snap.JSONDictionary;
        return json.copy;
    }];
}

@end