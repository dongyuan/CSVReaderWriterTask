//
//  CSVReaderWriter.m
//  CSVReaderWriter
//
//  Created by Eric Yuan on 14/03/2018.
//  Copyright © 2018 appcode.com.CSVReaderWriter. All rights reserved.
//

#import <CSVReaderWriter.h>

#define COMMA ','
#define TAB '\t'
#define NEW_LINE '\n'
#define DEFAULT_ENCODING NSUTF8StringEncoding
#define DEFAULT_DATA_READ_LENGHT 1

NSString *const CSVReadWriterErrorDomain = @"com.appcode.csvReadWriter";

@interface CSVReaderWriter() {
    NSFileHandle* inputHandle;
    NSFileHandle* outputHandle;
    NSString* inputFilePath;
    NSString* outputFilePath;
    unichar fileDelimiter;
}
- (nullable NSFileHandle*)setInputHandle;
- (nullable NSFileHandle*)setOutputHandle;
@end

@implementation CSVReaderWriter

- (instancetype)init {
    self = [super init];
    if (self) {
        fileDelimiter = TAB;
    }
    return self;
}

- (nullable instancetype)initWithFilePath:(nonnull NSString*)path delimiter:(unichar)delimiter {
    if ([NSFileHandle fileHandleForReadingAtPath:path] == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        inputFilePath = path;
        outputFilePath = path;
        fileDelimiter = delimiter;
    }
    
    return self;
}

- (BOOL)writeLine:(nonnull NSArray*)data {
    if([self setOutputHandle]) {
        NSString * lineDataWithDelimiter = [data componentsJoinedByString: [NSString stringWithFormat:@"%c", fileDelimiter]];
        if ([lineDataWithDelimiter length] > 0) {
            [outputHandle writeData:[[NSString stringWithFormat:@"%@\n", lineDataWithDelimiter] dataUsingEncoding: DEFAULT_ENCODING]];
            return true;
        }
    }
    return false;
}

- (nullable NSArray*)readLine {
    if([self setInputHandle]) {
        NSMutableArray* lineData = [[NSMutableArray alloc] init];
        unichar ch = 0;
        NSData* readData = nil;
        NSMutableString* chunk = [NSMutableString string];
        do {
            readData = [inputHandle readDataOfLength:DEFAULT_DATA_READ_LENGHT];
            if ([readData length] > 0) {
                [readData getBytes:&ch length:DEFAULT_DATA_READ_LENGHT];
                if(ch != NEW_LINE && ch != fileDelimiter) {
                    [chunk appendFormat:@"%c", ch];
                } else {
                    [lineData addObject:chunk];
                    chunk = [NSMutableString stringWithString:@""];
                }
            }
        } while(ch != NEW_LINE && [readData length] > 0);
        return lineData;
    }
    return nil;
}

- (nullable NSFileHandle*)setInputHandle {
    if (!inputHandle) {
        inputHandle = [NSFileHandle fileHandleForReadingAtPath:inputFilePath];
        if (inputHandle == nil) {
            [self failedWithErrorCode:CSVErrorCodeUnableOpenFileWithReadMode description: @"Can not open the file with read mode"];
        }
    }
    return inputHandle;
}

- (nullable NSFileHandle*)setOutputHandle {
    if (!outputHandle) {
        outputHandle = [NSFileHandle fileHandleForWritingAtPath:outputFilePath];
        if (outputHandle == nil) {
            [self failedWithErrorCode:CSVErrorCodeUnableOpenFileWithWriteMode description:@"Can not open the file with write mode"];
        }
    }
    return outputHandle;
}

- (void)close {
    [inputHandle closeFile]; //inputHandle is ivar, so reinit it
    inputHandle = nil;
    inputFilePath = nil;
    
    [outputHandle closeFile];
    outputHandle = nil;
    outputFilePath = nil;
}

- (void)failedWithErrorCode:(CSVErrorCode )errorCode description:(NSString *)description {
    if ([_delegate respondsToSelector:@selector(CSVReaderWriter:didFailWithError:)]) {
        NSError * error = [[NSError alloc] initWithDomain:CSVReadWriterErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: description}];
        [_delegate CSVReaderWriter:self didFailWithError:error];
    }
}

#pragma mark -
#pragma mark Deprecated Methods

- (void)open:(NSString *)path mode:(FileMode)mode {
    switch (mode) {
        case FileModeRead:
            if (inputFilePath != path) {
                [inputHandle closeFile];
                inputHandle = nil;
                inputFilePath = path;
            }
            [self setInputHandle];
            break;
        case FileModeWrite:
            if (outputFilePath != path) {
                [outputHandle closeFile];
                outputHandle = nil;
                outputFilePath = path;
            }
            [self setOutputHandle];
    }
}

- (BOOL)read:(nonnull NSMutableArray *)columns {
    NSArray *lineData = [self readLine];
    [columns addObjectsFromArray:lineData];
    return lineData != nil;
}

- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 {
    NSArray* lineArray = [[self readLine] copy];
    *column1 = lineArray.firstObject;
    *column2 = lineArray.count > 1 ? lineArray[1] : nil;
    return lineArray != nil;
}

- (void)write:(NSArray*)columns {
    [self writeLine:columns];
}
@end
