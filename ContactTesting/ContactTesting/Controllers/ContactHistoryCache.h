//
//  ContactHistoryCache.h
//  ContactHistoryCache
//
//  Created by Allie Shuldman on 11/12/21.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>



@interface ContactStoreHistory: NSObject

+(NSArray<CNChangeHistoryEvent*>*)getAllHistory:(CNContactStore*)store;
+(NSArray<CNChangeHistoryEvent*>*)checkForChangesStartingAt:(NSData*)startingToken store:(CNContactStore*)store;

+(NSArray<CNChangeHistoryEvent*>*)getAllHistory:(CNContactStore*)store excludingAuthors:(NSArray<NSString*>*)authors;
+(NSArray<CNChangeHistoryEvent*>*)checkForChangesStartingAt:(NSData*)startingToken store:(CNContactStore*)store excludingAuthors:(NSArray<NSString*>*)authors;

@end
