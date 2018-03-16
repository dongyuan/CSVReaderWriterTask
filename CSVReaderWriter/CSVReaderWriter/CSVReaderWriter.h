//
//  CSVReaderWriter.h
//  CSVReaderWriter
//
//  Created by Eric Yuan on 14/03/2018.
//  Copyright © 2018 appcode.com.CSVReaderWriter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

typedef NS_ENUM(NSInteger, CSVErrorCode) {
    CSVErrorCodeUnableOpenFileWithReadMode = 0,
    CSVErrorCodeUnableOpenFileWithWriteMode = 1
};

@class CSVReaderWriter;
@protocol CSVReaderWriterDelegate <NSObject>

@optional
/**
 * Sent when an error occured
 */
- (void)CSVReaderWriter:(nonnull CSVReaderWriter *)readerWriter didFailWithError:(nonnull NSError *)error;

@end

@interface CSVReaderWriter : NSObject

/**
 *  The delegate for the CSVReaderWriter
 */
@property (assign, nullable) id<CSVReaderWriterDelegate> delegate;

/**
 * Inititlise the CSVReaderWriter with file path and the delimiter char
 *
 * @param path the CSV file path
 * @param delimiter used to separate the data
 *
 * return CSVReaderWriter instance
 */
- (nullable instancetype)initWithFilePath:(nonnull NSString*)path delimiter:(unichar)delimiter;

/**
 * Read one row of data from the opened CSV file.
 *
 * return the row data, nil if the operation failed.
 */
- (nullable NSArray*)readLine;

/**
 * Write to the opened CSV file with the given columns data.
 * The data will be appended at the end of the file.
 *
 * @param data the columns data
 * return write operation successful
 */
- (BOOL)writeLine:(nonnull NSArray*)data;

/**
 * Close the CVS file
 */
- (void)close;

@end

#pragma mark - Deprecated APIs
@interface CSVReaderWriter (Deprecated)

//- (nullable instancetype)init NS_DESIGNATED_INITIALIZER __attribute((deprecated("Use initWithFilePath:delimiter instead")));

/**
 * Open the CSV file at the given path with Read/Write file mode
 *
 * @param path the CSV file path
 * @param mode read or write mode
 */
- (void)open:(nonnull NSString *)path mode:(FileMode)mode __attribute((deprecated("Use openWithFilePath:withMode:delimiter instead")));

/**
 * Read two consecutive columns of data
 *
 * @param column1 NSMutableString used to store the first column's data
 * @param column2 NSMutableString used to store the second column's data
 *
 * @return if the the reading two columns's data operation successful
 */
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 __attribute((deprecated("Please use readLine")));

/**
 * Read one row of data from the opened CSV file.
 *
 * @param columns array used to store the line data
 * return true if the the reading one line data operation successful
 */
- (BOOL)read:(nonnull NSMutableArray *)columns __attribute__((deprecated("Please use readLine")));

/**
 * Write to the opened CSV file with the given columns data.
 * The data will be appended at the end of the file.
 *
 * @param columns the columns data
 *
 */
- (void)write:(nonnull NSArray*)columns __attribute((deprecated("Please use writeLine:")));
@end
