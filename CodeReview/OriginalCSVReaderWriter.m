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

// we should use NS_ENUM, the file mode is exclusive. bitmask is used when several properties can be applied at the same time.
typedef NS_OPTIONS(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

@interface CSVReaderWriter : NSObject
// suggest changing the method name and parameters name to openFileAtPath:(NSString*)path withMode:(FileMode)mode, which following the naming convention
// It's also better to return BOOL indicating if the CSV file opened successfully
- (void)open:(NSString*)path mode:(FileMode)mode;
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2;
- (BOOL)read:(NSMutableArray*)columns;
- (void)write:(NSArray*)columns;
- (void)close;

@end

@implementation CSVReaderWriter {
    // private properties should be added in the private interface.
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
}

- (void)open:(NSString*)path mode:(FileMode)mode {
    // FileMode is a enum, better to use switch to make the code clean
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

    // use more meaningful name, such as lineData
    NSMutableString* str = [NSMutableString string];
    // check inputstream not nil and the file is opened
    while ([inputStream read:&ch maxLength:1] == 1) {
        // '\n' should be defined as a const
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
    // use constant for the delimiter char
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    
    if ([splitLine count] == 0) {
        *column1 = nil;
        *column2 = nil;
        return false;
    } // formatting the else should follow the parentheses and same line
    else {
        *column1 = [NSMutableString stringWithString:splitLine[FIRST_COLUMN]];
        *column2 = [NSMutableString stringWithString:splitLine[SECOND_COLUMN]];
        return true;
    }
}

// the implementation is almost identital to the read:column2, we should extract the common code
- (BOOL)read:(NSMutableArray*)columns {
    // the implementation only read up to 2 columns of data
    int FIRST_COLUMN = 0;
    int SECOND_COLUMN = 1;
    
    NSString* line = [self readLine];
    
    if ([line length] == 0) {
        columns[FIRST_COLUMN]=nil;
        columns[SECOND_COLUMN] = nil;
        return false;
    }
    // use constant for the delimiter char
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
    // hardcoded encoding, it's better to expose the option as parameter
    NSData* data = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* bytes = [data bytes];
    // check if outputStream is set and opened
    [outputStream write:bytes maxLength:[data length]];
    // bad name lf, batter to define as const
    unsigned char* lf = (unsigned char*)"\n";
    [outputStream write: lf maxLength: 1];
}

- (void)write:(NSArray*)columns {
    NSMutableString* outPut = [@"" mutableCopy];
    
    for (int i = 0; i < [columns count]; i++) {
        [outPut appendString: columns[i]];
        if (([columns count] - 1) != i) {
            // use constant for the delimiter char
            [outPut appendString: @"\t"];
        }
    }
    // need to check if the
    [self writeLine:outPut];
}

- (void)close {
    if (inputStream != nil) {
        [inputStream close];
        //inputStream is ivar, so reinit it, such as inputStream = nil
    }
    // looks as a typo, it should be outputStream
    if (inputStream != nil) {
        [inputStream close];
        
    }
}

@end
