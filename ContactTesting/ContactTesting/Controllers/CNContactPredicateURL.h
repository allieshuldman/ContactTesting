//
//  CNContactPredicateURL.h
//  CNContactPredicateURL
//
//  Created by Allie Shuldman on 10/21/21.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

@interface CNContact (CNContactPredicateURL)

+(NSPredicate*)predicateForContactsMatchingURL:(NSString*)url;

@end
