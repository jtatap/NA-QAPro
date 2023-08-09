public with sharing class searchAllContactsController {
 
 @AuraEnabled
 public static List <Contact> fetchContact(String searchKeyWord) {
  String searchKey = searchKeyWord + '%';
  List < Contact > returnList = new List < Contact > ();
  List < Contact > lstOfContacts = [select Id, Name,Email,Brand__c,LoyaltyID__c,Ecomm_Connected__c from Contact
                                   where Name LIKE: searchKey OR Email LIKE:searchKey OR LoyaltyID__c LIKE:searchKey LIMIT 500];
 
  for (Contact con: lstOfContacts) {
   returnList.add(con);
  }
  return returnList;
 }
}