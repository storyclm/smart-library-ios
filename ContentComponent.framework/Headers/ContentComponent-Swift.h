// Generated by Apple Swift version 4.2.1 (swiftlang-1000.11.42 clang-1000.11.45.1)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import CoreData;
@import CoreGraphics;
@import Foundation;
@import ObjectiveC;
@import WebKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="ContentComponent",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class NSEntityDescription;
@class NSManagedObjectContext;

SWIFT_CLASS_NAMED("BridgeCustomEvent")
@interface BridgeCustomEvent : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end



@class NSDate;

@interface BridgeCustomEvent (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic) int32_t contentId;
@property (nonatomic, strong) NSDate * _Nullable createdDate;
@property (nonatomic, copy) NSString * _Nullable eventId;
@property (nonatomic, copy) NSString * _Nullable eventKey;
@property (nonatomic, copy) NSString * _Nullable eventValue;
@property (nonatomic) BOOL sync;
@property (nonatomic) int32_t timeZone;
@property (nonatomic, copy) NSString * _Nullable userId;
@property (nonatomic, copy) NSString * _Nullable sessionId;
@end


SWIFT_CLASS_NAMED("BridgeMessage")
@interface BridgeMessage : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end



@class NSNumber;
@class NSData;

@interface BridgeMessage (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, copy) NSString * _Nullable response;
@property (nonatomic, copy) NSString * _Nullable command;
@property (nonatomic, strong) NSNumber * _Nullable contentId;
@property (nonatomic, strong) NSDate * _Nullable createdDate;
@property (nonatomic, strong) NSData * _Nullable data;
@property (nonatomic, copy) NSString * _Nullable guid;
@property (nonatomic) int16_t order;
@property (nonatomic, copy) NSString * _Nullable queue;
@end


SWIFT_CLASS("_TtC16ContentComponent6Client")
@interface Client : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class Presentation;
@class NSSet;

@interface Client (SWIFT_EXTENSION(ContentComponent))
- (void)addPresentationsObject:(Presentation * _Nonnull)value;
- (void)removePresentationsObject:(Presentation * _Nonnull)value;
- (void)addPresentations:(NSSet * _Nonnull)values;
- (void)removePresentations:(NSSet * _Nonnull)values;
@end


@interface Client (SWIFT_EXTENSION(ContentComponent))
- (nonnull instancetype)initWithContext:(NSManagedObjectContext * _Nonnull)context SWIFT_UNAVAILABLE;
@end


@interface Client (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, strong) NSNumber * _Nullable clientId;
@property (nonatomic, strong) NSDate * _Nullable created;
@property (nonatomic, copy) NSString * _Nullable email;
@property (nonatomic, copy) NSString * _Nullable imgId;
@property (nonatomic, copy) NSString * _Nullable longDescription;
@property (nonatomic, copy) NSString * _Nullable name;
@property (nonatomic, copy) NSString * _Nullable shortdescription;
@property (nonatomic, strong) NSDate * _Nullable synchronized;
@property (nonatomic, copy) NSString * _Nullable thumbImgId;
@property (nonatomic, strong) NSDate * _Nullable updatedDate;
@property (nonatomic, copy) NSString * _Nullable url;
@property (nonatomic, copy) NSSet<Presentation *> * _Nullable presentations;
@end


SWIFT_CLASS("_TtC16ContentComponent14ContentPackage")
@interface ContentPackage : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface ContentPackage (SWIFT_EXTENSION(ContentComponent))
- (nonnull instancetype)initWithContext:(NSManagedObjectContext * _Nonnull)context;
@end


@interface ContentPackage (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, copy) NSString * _Nullable blobId;
@property (nonatomic, strong) NSNumber * _Nullable contentPackageId;
@property (nonatomic, strong) NSDate * _Nullable created;
@property (nonatomic, strong) NSNumber * _Nullable fileSize;
@property (nonatomic, copy) NSString * _Nullable mimeType;
@property (nonatomic, strong) NSNumber * _Nullable revision;
@property (nonatomic, strong) NSDate * _Nullable updatedDate;
@property (nonatomic, strong) Presentation * _Nullable presentation;
@end


SWIFT_CLASS("_TtC16ContentComponent28ContentPackageDownloadingNow")
@interface ContentPackageDownloadingNow : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
@end




SWIFT_CLASS("_TtC16ContentComponent9MediaFile")
@interface MediaFile : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface MediaFile (SWIFT_EXTENSION(ContentComponent))
- (nonnull instancetype)initWithContext:(NSManagedObjectContext * _Nonnull)context SWIFT_UNAVAILABLE;
@end


@interface MediaFile (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, copy) NSString * _Nullable blobId;
@property (nonatomic, strong) NSDate * _Nullable created;
@property (nonatomic, copy) NSString * _Nullable fileName;
@property (nonatomic, strong) NSNumber * _Nullable fileSize;
@property (nonatomic, strong) NSNumber * _Nullable isAvailableForSharing;
@property (nonatomic, strong) NSNumber * _Nullable mediaFileId;
@property (nonatomic, copy) NSString * _Nullable mimeType;
@property (nonatomic, strong) NSNumber * _Nullable revision;
@property (nonatomic, copy) NSString * _Nullable title;
@property (nonatomic, strong) NSDate * _Nullable updatedDate;
@property (nonatomic, strong) Presentation * _Nullable presentation;
@end


SWIFT_CLASS("_TtC16ContentComponent23MediaFileDownloadingNow")
@interface MediaFileDownloadingNow : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC16ContentComponent12Presentation")
@interface Presentation : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class Slide;

@interface Presentation (SWIFT_EXTENSION(ContentComponent))
- (void)addSlidesObject:(Slide * _Nonnull)value;
- (void)removeSlidesObject:(Slide * _Nonnull)value;
- (void)addSlides:(NSSet * _Nonnull)values;
- (void)removeSlides:(NSSet * _Nonnull)values;
@end


@interface Presentation (SWIFT_EXTENSION(ContentComponent))
- (void)addMediaFilesObject:(MediaFile * _Nonnull)value;
- (void)removeMediaFilesObject:(MediaFile * _Nonnull)value;
- (void)addMediaFiles:(NSSet * _Nonnull)values;
- (void)removeMediaFiles:(NSSet * _Nonnull)values;
@end


@interface Presentation (SWIFT_EXTENSION(ContentComponent))
- (nonnull instancetype)initWithContext:(NSManagedObjectContext * _Nonnull)context;
@end


@interface Presentation (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, strong) NSDate * _Nullable created;
@property (nonatomic, strong) NSNumber * _Nullable debugModeEnabled;
@property (nonatomic, copy) NSString * _Nullable imgId;
@property (nonatomic, copy) NSString * _Nullable longDescription;
@property (nonatomic, copy) NSString * _Nullable map;
@property (nonatomic, strong) NSNumber * _Nullable mapEnabled;
@property (nonatomic, strong) NSNumber * _Nullable mapType;
@property (nonatomic, copy) NSString * _Nullable name;
@property (nonatomic, strong) NSNumber * _Nullable needConfirmation;
@property (nonatomic, strong) NSNumber * _Nullable order;
@property (nonatomic, strong) NSNumber * _Nullable presentationId;
@property (nonatomic, strong) NSNumber * _Nullable previewMode;
@property (nonatomic, strong) NSData * _Nullable rawData;
@property (nonatomic, strong) NSNumber * _Nullable revision;
@property (nonatomic, copy) NSString * _Nullable shortdescription;
@property (nonatomic, strong) NSNumber * _Nullable skip;
@property (nonatomic, strong) NSNumber * _Nullable syncState;
@property (nonatomic, copy) NSString * _Nullable thumbImgId;
@property (nonatomic, strong) NSDate * _Nullable updatedDate;
@property (nonatomic, strong) NSNumber * _Nullable visibility;
@property (nonatomic, strong) NSNumber * _Nullable opened;
@property (nonatomic, strong) Client * _Nullable client;
@property (nonatomic, strong) ContentPackage * _Nullable contentPackage;
@property (nonatomic, copy) NSSet<MediaFile *> * _Nullable mediaFiles;
@property (nonatomic, copy) NSSet<Slide *> * _Nullable slides;
@end

@class NSCoder;

SWIFT_CLASS("_TtC16ContentComponent9SCLMError")
@interface SCLMError : NSError
- (nonnull instancetype)initWithDomain:(NSString * _Nonnull)domain code:(NSInteger)code userInfo:(NSDictionary<NSString *, id> * _Nullable)dict OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class WKNavigation;
@class WKWebViewConfiguration;

SWIFT_CLASS("_TtC16ContentComponent11SCLMWebView")
@interface SCLMWebView : WKWebView <WKNavigationDelegate>
- (void)webView:(WKWebView * _Nonnull)webView didStartProvisionalNavigation:(WKNavigation * _Null_unspecified)navigation;
- (void)webView:(WKWebView * _Nonnull)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation * _Null_unspecified)navigation;
- (void)webView:(WKWebView * _Nonnull)webView didFailProvisionalNavigation:(WKNavigation * _Null_unspecified)navigation withError:(NSError * _Nonnull)error;
- (void)webView:(WKWebView * _Nonnull)webView didCommitNavigation:(WKNavigation * _Null_unspecified)navigation;
- (void)webView:(WKWebView * _Nonnull)webView didFinishNavigation:(WKNavigation * _Null_unspecified)navigation;
- (void)webView:(WKWebView * _Nonnull)webView didFailNavigation:(WKNavigation * _Null_unspecified)navigation withError:(NSError * _Nonnull)error;
- (nonnull instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration * _Nonnull)configuration OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC16ContentComponent5Slide")
@interface Slide : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Slide (SWIFT_EXTENSION(ContentComponent))
- (nonnull instancetype)initWithContext:(NSManagedObjectContext * _Nonnull)context;
@end


@interface Slide (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, strong) NSDate * _Nullable created;
@property (nonatomic, copy) NSString * _Nullable linkedSlides;
@property (nonatomic, copy) NSString * _Nullable name;
@property (nonatomic, copy) NSString * _Nullable pageSource;
@property (nonatomic, strong) NSNumber * _Nullable revision;
@property (nonatomic, strong) NSNumber * _Nullable slideId;
@property (nonatomic, copy) NSString * _Nullable swipeNext;
@property (nonatomic, copy) NSString * _Nullable swipePrevious;
@property (nonatomic, strong) NSDate * _Nullable updatedDate;
@property (nonatomic, strong) Presentation * _Nullable presentation;
@end


SWIFT_CLASS("_TtC16ContentComponent4User")
@interface User : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface User (SWIFT_EXTENSION(ContentComponent))
@property (nonatomic, strong) NSDate * _Nullable birthDate;
@property (nonatomic, strong) NSNumber * _Nullable code;
@property (nonatomic, copy) NSString * _Nullable email;
@property (nonatomic, strong) NSNumber * _Nullable gender;
@property (nonatomic, copy) NSString * _Nullable location;
@property (nonatomic, copy) NSString * _Nullable name;
@property (nonatomic, copy) NSString * _Nullable phoneNumber;
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
