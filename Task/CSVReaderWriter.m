/*
 A junior developer was tasked with writing a reusable implementation for a mass mailing application to read and write text files that hold tab separated data.
 
 His implementation, although it works and meets the needs of the application, is of very low quality.
 
 Your task:
 
 - Identify and annotate the shortcomings in the current implementation as if you were doing a code review, using comments in the source files.
 
 - Refactor the CSVReaderWriter implementation into clean, idiomatic, elegant, rock-solid & well performing code, without over-engineering.
 
 - Where you make trade offs, comment & explain.
 
 - Assume this code is in production and backwards compatibility must be maintained. Therefore if you decide to change the public interface, please deprecate the existing methods. Feel free to evolve the code in other ways though. You have carte blanche while respecting the above constraints. 
 */

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

@interface CSVReaderWriter : NSObject

- (void)open:(NSString*)path mode:(FileMode)mode;
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2;
- (BOOL)read:(NSMutableArray*)columns;
- (void)write:(NSArray*)columns;
- (void)close;

@end

@implementation CSVReaderWriter {
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
}

- (void)open:(NSString*)path mode:(FileMode)mode {
    if (mode == FileModeRead) {
        inputStream = [NSInputStream inputStreamWithFileAtPath:path];
        [inputStream open];
    }
    else if (mode == FileModeWrite) {
        outputStream = [NSOutputStream outputStreamToFileAtPath:path
                                                         append:NO];
        [outputStream open];
    }
    else {
        NSException* ex = [NSException exceptionWithName:@"UnknownFileModeException"
                                                  reason:@"Unknown file mode specified"
                                                userInfo:nil];
        @throw ex;
    }
}

- (NSString*)readLine {
    uint8_t ch = 0;
    NSMutableString* str = [NSMutableString string];
    while ([inputStream read:&ch maxLength:1] == 1) {
        if (ch == '\n')
            break;
        [str appendFormat:@"%c", ch];
    }
    return str;
}

- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 {
    int FIRST_COLUMN = 0;
    int SECOND_COLUMN = 1;
    
    NSString* line = [self readLine];
    
    if ([line length] == 0) {
        *column1 = nil;
        *column2 = nil;
        return false;
    }
    
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    
    if ([splitLine count] == 0) {
        *column1 = nil;
        *column2 = nil;
        return false;
    }
    else {
        *column1 = [NSMutableString stringWithString:splitLine[FIRST_COLUMN]];
        *column2 = [NSMutableString stringWithString:splitLine[SECOND_COLUMN]];
        return true;
    }
}

- (BOOL)read:(NSMutableArray*)columns {
    int FIRST_COLUMN = 0;
    int SECOND_COLUMN = 1;
    
    NSString* line = [self readLine];
    
    if ([line length] == 0) {
        columns[FIRST_COLUMN]=nil;
        columns[SECOND_COLUMN] = nil;
        return false;
    }
    
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    
    if ([splitLine count] == 0) {
        columns[FIRST_COLUMN] = nil;
        columns[SECOND_COLUMN] = nil;
        return false;
    }
    else {
        columns[FIRST_COLUMN] = splitLine[FIRST_COLUMN];
        columns[SECOND_COLUMN] = splitLine[SECOND_COLUMN];
        return true;
    }
}

- (void)writeLine:(NSString*)line {
    NSData* data = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* bytes = [data bytes];
    [outputStream write:bytes maxLength:[data length]];
    
    unsigned char* lf = (unsigned char*)"\n";
    [outputStream write: lf maxLength: 1];
}

- (void)write:(NSArray*)columns {
    NSMutableString* outPut = [@"" mutableCopy];
    
    for (int i = 0; i < [columns count]; i++) {
        [outPut appendString: columns[i]];
        if (([columns count] - 1) != i) {
            [outPut appendString: @"\t"];
        }
    }
    
    [self writeLine:outPut];
}

- (void)close {
    if (inputStream != nil) {
        [inputStream close];
    }
    if (inputStream != nil) {
        [inputStream close];
    }
}

@end