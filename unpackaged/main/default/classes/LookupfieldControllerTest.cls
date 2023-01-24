/**
* @description       : test class for LookupfieldController
* @author            :Hemadri Ravilla
* @last modified on  : 06-10-2021
* @last modified by  : Hemadri Ravilla
**/
@isTest
public class LookupfieldControllerTest {
    private static testmethod void getObjectDetailsTest()
    {
        Account acc = new Account();
        acc.Name = 'generic Account' + Math.random();
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='1';
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = con.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = acc.Id
        );
        insert genRecAcct;

        LookupfieldController.getObjectDetails('Contact');
        List<string> lstStr=new List<string>();
        lstStr.add('Name');
        LookupfieldController.GetRecord('Contact',lstStr,con.id);
        LookupfieldController.GetRecentRecords('Contact',lstStr,1);
        LookupfieldController.fetchContact('generic');
        LookupfieldController.SearchRecords('Contact',lstStr,lstStr,'generic','CreatedDate','DESC',20,null);
    }
}