//
//  CSVReaderWriterTests.m
//  CSVReaderWriterTests
//
//  Created by Eric Yuan on 14/03/2018.
//  Copyright © 2018 appcode.com.CSVReaderWriter. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CSVReaderWriter/CSVReaderWriter.h>

NSString *const CSVExtension = @"csv";
NSString *const SampleFile = @"sample";
NSString *const SampleFileSeperatedByComma = @"sample2";
NSString *const TestWritingFile = @"csvReaderWriterTest";
NSUInteger const NumberOfColumnsinTestFile = 18;

@interface CSVReaderWriterTests : XCTestCase<CSVReaderWriterDelegate> {
    CSVReaderWriter *csvReaderWriter;
    NSError *testError;
    NSString *sampleFilePath;
    NSString *filePathForWriting;
}

@end

@implementation CSVReaderWriterTests

- (void)setUp {
    [super setUp];
    sampleFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:SampleFile ofType:CSVExtension];
    filePathForWriting = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", TestWritingFile, CSVExtension]];
    [[NSFileManager defaultManager] createFileAtPath:filePathForWriting contents:nil attributes:nil];
}

- (void)tearDown {
    [super tearDown];
    [csvReaderWriter close];
    csvReaderWriter = nil;
    testError = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePathForWriting error:nil];
}

#pragma mark Deprecated tests

- (void)testDeprecatedInit_success {
    CSVReaderWriter *csvReaderWriterInstance = [[CSVReaderWriter alloc] init];
    XCTAssertNotNil(csvReaderWriterInstance);
}

- (void)testOpenFileReadMode_success {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    csvReaderWriter.delegate = self;
    [csvReaderWriter open:sampleFilePath mode:FileModeRead];
    XCTAssertNil(testError);
}

- (void)testOpenFileWithReadMode_failed_invalidFilePath {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    csvReaderWriter.delegate = self;
    [csvReaderWriter open:@"" mode:FileModeRead];
    XCTAssertNotNil(testError);
    XCTAssertEqual(CSVErrorCodeUnableOpenFileWithReadMode, testError.code);
}

- (void)testOpenFileWriteMode_success {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    csvReaderWriter.delegate = self;
    [csvReaderWriter open:sampleFilePath mode:FileModeWrite];
    XCTAssertNil(testError);
}

- (void)testOpenFileWithWriteMode_failed_invalidFilePath {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    csvReaderWriter.delegate = self;
    [csvReaderWriter open:@"" mode:FileModeWrite];
    XCTAssertNotNil(testError);
    XCTAssertEqual(CSVErrorCodeUnableOpenFileWithWriteMode, testError.code);
}

- (void)testRead_success_openFileFirst {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    [csvReaderWriter open:sampleFilePath mode:FileModeRead];
    XCTAssertTrue([csvReaderWriter read:mutableArray]);
    XCTAssertEqual(NumberOfColumnsinTestFile, [mutableArray count]);
}

- (void)testRead_failed_notOpenFileFirst {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    XCTAssertFalse([csvReaderWriter read:mutableArray]);
}

- (void)testRead_noData_wrongFormatCSV {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    NSString *sampleSeparatedByCommaFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:SampleFileSeperatedByComma ofType:CSVExtension];
    [csvReaderWriter open:sampleSeparatedByCommaFilePath mode:FileModeRead];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    XCTAssertTrue([csvReaderWriter read:mutableArray]);
    XCTAssertEqual(1, [mutableArray count]);
}

- (void)testReadTwoColumns_success_openFileFirst {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    [csvReaderWriter open:sampleFilePath mode:FileModeRead];
    NSMutableString *column1 = nil;
    NSMutableString *column2 = nil;
    XCTAssertTrue([csvReaderWriter read:&column1 column2:&column2]);
    XCTAssertEqualObjects(@"481133", column1);
    XCTAssertEqualObjects(@"FL", column2);
}

- (void)testReadTwoColumns_failed_notOpenFileFirst {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    NSMutableString *column1 = nil;
    NSMutableString *column2 = nil;
    XCTAssertFalse([csvReaderWriter read:&column1 column2:&column2]);
}

- (void)testWrite_success {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    [csvReaderWriter open:filePathForWriting mode:FileModeWrite];
    NSArray *testDataArray = @[@"481133",@"FL"];
    [csvReaderWriter write:testDataArray];
    [csvReaderWriter close];

    [csvReaderWriter open:filePathForWriting mode:FileModeRead];
    NSMutableString *column1 = nil;
    NSMutableString *column2 = nil;
    XCTAssertTrue([csvReaderWriter read:&column1 column2:&column2]);
    XCTAssertEqualObjects(@"481133", column1);
    XCTAssertEqualObjects(@"FL", column2);
}

- (void)testReadWrite_success_sameTime {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    [csvReaderWriter open:sampleFilePath mode:FileModeRead];
    [csvReaderWriter open:filePathForWriting mode:FileModeWrite];
    
    NSMutableArray *originalData = [[NSMutableArray alloc] init];
    XCTAssertTrue([csvReaderWriter read:originalData]);
    XCTAssertEqual(NumberOfColumnsinTestFile, [originalData count]);
    
    NSArray *dataWriting = [originalData copy];
    [csvReaderWriter write:dataWriting];
    
    [csvReaderWriter open:filePathForWriting mode:FileModeRead];
    NSMutableArray *dataWritten = [[NSMutableArray alloc] init];
    XCTAssertTrue([csvReaderWriter read:dataWritten]);
                            
    XCTAssertEqualObjects(originalData, dataWritten);
}

- (void)testClose_success_deprecatedInit {
    csvReaderWriter = [[CSVReaderWriter alloc] init];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    [csvReaderWriter open:sampleFilePath mode:FileModeRead];
    XCTAssertTrue([csvReaderWriter read:mutableArray]);
    XCTAssertEqual(NumberOfColumnsinTestFile, [mutableArray count]);
    
    [csvReaderWriter close];
    XCTAssertFalse([csvReaderWriter read:mutableArray]);
}

#pragma mark tests
- (void)testReaderWriterInit_success {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:sampleFilePath delimiter:'\t'];
    XCTAssertNotNil(csvReaderWriter);
}

- (void)testReaderWriterInit_fail_invalidFilePath {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:@"" delimiter:'\t'];
    XCTAssertNil(csvReaderWriter);
}

- (void)testReadLine_success {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:sampleFilePath delimiter:'\t'];
    NSArray *array =[csvReaderWriter readLine];
    XCTAssertNotNil (array);
    XCTAssertEqual(NumberOfColumnsinTestFile, [array count]);
}

- (void)testReadLine_success_commaDelimiter {
    NSString *sampleTestSepratedByCommaFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:SampleFileSeperatedByComma ofType:CSVExtension];
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:sampleTestSepratedByCommaFilePath delimiter:','];
    NSArray *array =[csvReaderWriter readLine];
    XCTAssertNotNil (array);
    XCTAssertEqual(NumberOfColumnsinTestFile, [array count]);
}

- (void)testReadLine_failed_fileClosed {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:sampleFilePath delimiter:'\t'];
    csvReaderWriter.delegate = self;
    [csvReaderWriter close];
    NSArray *array =[csvReaderWriter readLine];
    XCTAssertNil (array);
    XCTAssertNotNil(testError);
    XCTAssertEqual(CSVErrorCodeUnableOpenFileWithReadMode, testError.code);
}

- (void)testWriteLine_success {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:filePathForWriting delimiter:'\t'];
    NSArray *testDataArray = @[@"481133",@"FL"];
    XCTAssertTrue([csvReaderWriter writeLine:testDataArray]);

    NSArray *array = [csvReaderWriter readLine];
    XCTAssertNotNil (array);
    XCTAssertEqualObjects(testDataArray, array);
}

- (void)testClose_success_readMode {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:sampleFilePath delimiter:'\t'];
    csvReaderWriter.delegate = self;
    NSArray *array = [csvReaderWriter readLine];
    XCTAssertNotNil(array);
    XCTAssertEqual(NumberOfColumnsinTestFile, [array count]);

    [csvReaderWriter close];
    array = [csvReaderWriter readLine];
    XCTAssertNil (array);
    XCTAssertNotNil(testError);
    XCTAssertEqual(CSVErrorCodeUnableOpenFileWithReadMode, testError.code);
}

- (void)testClose_success_writeMode {
    csvReaderWriter = [[CSVReaderWriter alloc] initWithFilePath:filePathForWriting delimiter:'\t'];
    csvReaderWriter.delegate = self;
    NSArray *testDataArray = @[@"481133",@"FL"];
    XCTAssertTrue([csvReaderWriter writeLine:testDataArray]);
    
    [csvReaderWriter close];
    XCTAssertFalse([csvReaderWriter writeLine:testDataArray]);
    XCTAssertNotNil(testError);
    XCTAssertEqual(CSVErrorCodeUnableOpenFileWithWriteMode, testError.code);
}

- (void)CSVReaderWriter:(nonnull CSVReaderWriter *)readerWriter didFailWithError:(nonnull NSError *)error {
    testError = error;
}
@end
