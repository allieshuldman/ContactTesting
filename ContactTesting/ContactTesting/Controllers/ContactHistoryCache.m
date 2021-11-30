//
//  ContactHistoryCache.m
//  ContactHistoryCache
//
//  Created by Allie Shuldman on 11/12/21.
//

#import "ContactHistoryCache.h"
#import <Contacts/Contacts.h>


@implementation ContactStoreHistory: NSObject

+(NSArray<CNChangeHistoryEvent*>*)getAllHistory:(CNContactStore*)store
{
  CNChangeHistoryFetchRequest* request = [[CNChangeHistoryFetchRequest alloc] init];
  request.additionalContactKeyDescriptors = @[ CNContactEmailAddressesKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName] ];

  return [self executeRequest:store request:request];
}

+(NSArray<CNChangeHistoryEvent*>*)checkForChangesStartingAt:(NSData*)startingToken store:(CNContactStore*)store
{
  CNChangeHistoryFetchRequest* request = [[CNChangeHistoryFetchRequest alloc] init];
  request.startingToken = startingToken;
  request.additionalContactKeyDescriptors = @[ CNContactEmailAddressesKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName] ];

  return [self executeRequest:store request:request];
}

+(NSArray<CNChangeHistoryEvent*>*)getAllHistory:(CNContactStore*)store excludingAuthors:(NSArray<NSString*>*)authors
{
  CNChangeHistoryFetchRequest* request = [[CNChangeHistoryFetchRequest alloc] init];
  request.excludedTransactionAuthors = authors;
  request.additionalContactKeyDescriptors = @[ CNContactEmailAddressesKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName] ];

  return [self executeRequest:store request:request];
}

+(NSArray<CNChangeHistoryEvent*>*)checkForChangesStartingAt:(NSData*)startingToken store:(CNContactStore*)store excludingAuthors:(NSArray<NSString*>*)authors
{
  CNChangeHistoryFetchRequest* request = [[CNChangeHistoryFetchRequest alloc] init];
  request.excludedTransactionAuthors = authors;
  request.startingToken = startingToken;
  request.additionalContactKeyDescriptors = @[ CNContactEmailAddressesKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName] ];

  return [self executeRequest:store request:request];
}


+(NSArray<CNChangeHistoryEvent*>*)executeRequest:(CNContactStore*)store request:(CNChangeHistoryFetchRequest*)request
{
  NSError* fetchError = nil;
  CNFetchResult<NSEnumerator<CNChangeHistoryEvent *> *> * result = [store enumeratorForChangeHistoryFetchRequest:request error:&fetchError];

  if (result == nil)
  {
    NSLog(@"Failed to get change history %@", fetchError);
    return [NSArray new];
  }

  return result.value.allObjects;
}

@end
