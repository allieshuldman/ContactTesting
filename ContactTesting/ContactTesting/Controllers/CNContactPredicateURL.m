//
//  CNContactPredicateURL.m
//  CNContactPredicateURL
//
//  Created by Allie Shuldman on 10/21/21.
//

#import "CNContactPredicateURL.h"
#import <Contacts/Contacts.h>

@implementation CNContact (CNContactPredicateURL)

+(NSPredicate*)predicateForContactsMatchingURL:(NSString*)url {
  SEL predicateForContactMatchingURLString = NSSelectorFromString(@"predicateForContactMatchingURLString:");
  NSPredicate* result = [[CNContact class] performSelector:predicateForContactMatchingURLString withObject:url];
  return result;
}

@end
