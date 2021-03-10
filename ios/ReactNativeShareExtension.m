#import "ReactNativeShareExtension.h"
#import "React/RCTRootView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define URL_IDENTIFIER @"public.url"
#define IMAGE_IDENTIFIER @"public.image"
#define TEXT_IDENTIFIER (NSString *)kUTTypePlainText

NSExtensionContext* extensionContext;
UIView *rootView;

@implementation ReactNativeShareExtension {
    NSTimer *autoTimer;
    NSString* type;
    NSString* value;
}

- (UIView*) shareView {
  return nil;
}

RCT_EXPORT_MODULE();

- (void)viewDidLoad {
  [super viewDidLoad];

  //object variable for extension doesn't work for react-native. It must be assign to gloabl
  //variable extensionContext. in this way, both exported method can touch extensionContext
  extensionContext = self.extensionContext;

  rootView = [self shareView];
  if (rootView.backgroundColor == nil) {
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.1];
  }

  self.view = rootView;
}


RCT_EXPORT_METHOD(close) {
  [extensionContext completeRequestReturningItems:nil
                                completionHandler:nil];
}



RCT_EXPORT_METHOD(openURL:(NSString *)url) {
  UIApplication *application = [UIApplication sharedApplication];
  NSURL *urlToOpen = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [application openURL:urlToOpen options:@{} completionHandler: nil];
}


RCT_REMAP_METHOD(data,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  [self extractDataFromContext:extensionContext withCallback:^(NSArray* data, NSException* err) {
    if(err) {
      reject(@"error", err.description, nil);
    } else {
      resolve(data);
    }
  }];
}


RCT_REMAP_METHOD(getShareExtensionPosition,
                 getShareExtensionPositionWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    if (rootView == nil) {
        resolve();
        return;
    }
    
    CGRect rootViewPosition = [rootView convertRect:rootView.frame toCoordinateSpace:[UIScreen mainScreen].fixedCoordinateSpace];

    NSDictionary *result = [[NSDictionary alloc] init];
    [result setValue:[NSNumber numberWithFloat:rootViewPosition.origin.x] forKey:@"x"];
    [result setValue:[NSNumber numberWithFloat:rootViewPosition.origin.y] forKey:@"y"];
    [result setValue:[NSNumber numberWithFloat:rootViewPosition.size.width] forKey:@"width"];
    [result setValue:[NSNumber numberWithFloat:rootViewPosition.size.height] forKey:@"height"];

    resolve(@[result]);
}

- (void)processShareAttachment:(NSEnumerator<NSItemProvider*> *)attachmentEnumerator
                     intoArray:(NSMutableArray*)dataArray
         withCompletionHandler:(void(^)(NSArray *dataArray, NSException *exception))handler {
  @try {
    NSItemProvider *provider = [attachmentEnumerator nextObject];
    if (!provider) {
      handler(dataArray, nil);
      return;
    }

    if ([provider hasItemConformingToTypeIdentifier:URL_IDENTIFIER]) {
      [provider loadItemForTypeIdentifier:URL_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
        @try {
          NSURL *url = (NSURL *)item;
          [dataArray addObject:[url absoluteString]];
          [self processShareAttachment:attachmentEnumerator intoArray:dataArray withCompletionHandler:handler];
        } @catch (NSException *exception) {
          if (handler) {
            handler(nil, exception);
          }
        }
      }];
    } else if ([provider hasItemConformingToTypeIdentifier:TEXT_IDENTIFIER]){
      [provider loadItemForTypeIdentifier:TEXT_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
        @try {
          NSString *text = (NSString *)item;
          [dataArray addObject:text];

          [self processShareAttachment:attachmentEnumerator intoArray:dataArray withCompletionHandler:handler];
        } @catch (NSException *exception) {
          if (handler) {
            handler(nil, exception);
          }
        }
      }];
    } else {
      [self processShareAttachment:attachmentEnumerator intoArray:dataArray withCompletionHandler:handler];
    }
  } @catch (NSException *exception) {
    if (handler) {
      handler(nil, exception);
    }
  }

}

- (void)extractDataFromContext:(NSExtensionContext *)context withCallback:(void(^)(NSArray *dataArray, NSException *exception))callback {
  @try {
    NSExtensionItem *item = [context.inputItems firstObject];
    NSMutableArray *parsedAttachments = [NSMutableArray array];

    [self processShareAttachment:[item.attachments objectEnumerator] intoArray:parsedAttachments withCompletionHandler:callback];
  } @catch (NSException *exception) {
    if (callback) {
      callback(nil, exception);
    }
  }
}

+ (BOOL)requiresMainQueueSetup
{
    // Not sure if this is required or not here, setting to yes because of some race conditions
    // we're seeing in the share extension load process
    return YES;
}

@end
