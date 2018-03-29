//
//  KTVVPPipeline.m
//  KTVVideoProcessDemo
//
//  Created by Single on 2018/3/26.
//  Copyright © 2018年 Single. All rights reserved.
//

#import "KTVVPPipeline.h"
#import "KTVVPPipelinePrivate.h"

@interface KTVVPPipeline () <KTVVPPipelinePrivate>

@property (nonatomic, strong) NSMutableArray <id <KTVVPFrameInput>> * outputsInternal;

@end

@implementation KTVVPPipeline

- (instancetype)initWithContext:(KTVVPContext *)context
                  filterClasses:(NSArray <Class> *)filterClasses
{
    if (self = [super init])
    {
        _context = context;
        _filterClasses = filterClasses;
        _needFlushBeforOutput = YES;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)setupIfNeeded
{
    if (!_didSetup)
    {
        [self setupInternal];
        _didSetup = YES;
    }
}

- (void)setupInternal {}
- (void)inputFrame:(KTVVPFrame *)frame fromSource:(id)source {}


#pragma mark - Output

- (NSArray <id <KTVVPFrameInput>> *)outputs
{
    return [_outputsInternal copy];
}

- (void)addOutput:(id <KTVVPFrameInput>)output
{
    if (!_outputsInternal)
    {
        _outputsInternal = [NSMutableArray array];
    }
    if (![_outputsInternal containsObject:output])
    {
        [_outputsInternal addObject:output];
    }
}

- (void)addOutputs:(NSArray <id<KTVVPFrameInput>> *)outputs
{
    for (id<KTVVPFrameInput> obj in outputs)
    {
        [self addOutput:obj];
    }
}

- (void)removeOutput:(id <KTVVPFrameInput>)output
{
    [_outputsInternal removeObject:output];
}

- (void)removeOutputs:(NSArray <id<KTVVPFrameInput>> *)outputs
{
    for (id<KTVVPFrameInput> obj in outputs)
    {
        [self removeOutput:obj];
    }
}

- (void)removeAllOutputs
{
    [_outputsInternal removeAllObjects];
}

- (void)outputFrame:(KTVVPFrame *)frame
{
    if (_needFlushBeforOutput)
    {
        glFlush();
    }
    [frame lock];
    for (id <KTVVPFrameInput> obj in _outputsInternal)
    {
        [obj inputFrame:frame fromSource:self];
    }
    [frame unlock];
}

@end
