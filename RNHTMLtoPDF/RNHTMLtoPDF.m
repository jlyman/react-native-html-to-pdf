
//  Created by Christopher on 9/3/15.

#import <UIKit/UIKit.h>
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTView.h"
#import "RNHTMLtoPDF.h"
#import "UIView+React.h"
#import "RCTUtils.h"

#define PDFSize CGSizeMake(612,792)

@implementation UIPrintPageRenderer (PDF)
- (NSData*) printToPDF:(NSDictionary *)auxDictionary
{
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, self.paperRect, auxDictionary);
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];

    CGRect bounds = UIGraphicsGetPDFContextBounds();

    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        [self drawPageAtIndex: i inRect: bounds];
    }

    UIGraphicsEndPDFContext();
    return pdfData;
}
@end

@implementation RNHTMLtoPDF {
    RCTEventDispatcher *_eventDispatcher;
    RCTPromiseResolveBlock _resolveBlock;
    RCTPromiseRejectBlock _rejectBlock;
    NSString *_html;
    NSString *_fileName;
    NSString *_filePath;
    NSString *_ownerPassword;
    NSString *_userPassword;
    NSNumber *_encryptionKeyLength;
    NSMutableDictionary *_auxDictionary;
    CGSize _PDFSize;
    UIWebView *_webView;
    float _padding;
    BOOL autoHeight;
}

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

- (instancetype)init
{
    if (self = [super init]) {
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.delegate = self;
        [self addSubview:_webView];
        autoHeight = false;
    }
    return self;
}

RCT_EXPORT_METHOD(convert:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    if (options[@"html"]){
        _html = [RCTConvert NSString:options[@"html"]];
    }

    if (options[@"fileName"]){
        _fileName = [RCTConvert NSString:options[@"fileName"]];
    } else {
        _fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    }

    if (options[@"directory"] && [options[@"directory"] isEqualToString:@"docs"]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];

        _filePath = [NSString stringWithFormat:@"%@/%@.pdf", documentsPath, _fileName];
    } else {
        _filePath = [NSString stringWithFormat:@"%@%@.pdf", NSTemporaryDirectory(), _fileName];
    }

    if (options[@"height"] && options[@"width"]) {
        float width = [RCTConvert float:options[@"width"]];
        float height = [RCTConvert float:options[@"height"]];
        _PDFSize = CGSizeMake(width, height);
    } else {
        _PDFSize = PDFSize;
    }

    if (options[@"padding"]) {
        _padding = [RCTConvert float:options[@"padding"]];
    } else {
        _padding = 10.0f;
    }
    
    _auxDictionary = [[NSMutableDictionary alloc] init];
    
    if (options[@"ownerPassword"]) {
        _ownerPassword = [RCTConvert NSString:options[@"ownerPassword"]];
        [_auxDictionary setObject:_ownerPassword forKey:(NSString *)kCGPDFContextOwnerPassword];
    }
    
    if (options[@"userPassword"]) {
        _userPassword = [RCTConvert NSString:options[@"userPassword"]];
        [_auxDictionary setObject:_userPassword forKey:(NSString *)kCGPDFContextUserPassword];
    }
    
    if (options[@"encryptionKeyLength"]) {
        _encryptionKeyLength = [RCTConvert NSNumber:options[@"encryptionKeyLength"]];
        [_auxDictionary setObject:_encryptionKeyLength forKey:(NSString *)kCGPDFContextEncryptionKeyLength];
    }

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];

    [_webView loadHTMLString:_html baseURL:baseURL];

    _resolveBlock = resolve;
    _rejectBlock = reject;

}

- (void)webViewDidFinishLoad:(UIWebView *)awebView
{
    if (awebView.isLoading)
        return;

    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:awebView.viewPrintFormatter startingAtPageAtIndex:0];

    // Define the printableRect and paperRect
    // If the printableRect defines the printable area of the page
    CGRect paperRect = CGRectMake(0, 0, _PDFSize.width, _PDFSize.height);
    CGRect printableRect = CGRectMake(_padding, _padding, _PDFSize.width-(_padding * 2), _PDFSize.height-(_padding * 2));

    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];

    NSData *pdfData = [render printToPDF:_auxDictionary];

    if (pdfData) {
        [pdfData writeToFile:_filePath atomically:YES];
        _resolveBlock(_filePath);
    } else {
        NSError *error;
        _rejectBlock(RCTErrorUnspecified, nil, RCTErrorWithMessage(error.description));
    }
}

@end
