@isTest
public class RectifyDataEmailServiceClassTest {

    public TestMethod static void callEmailService(){
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
        
        case cse = new Case();
        cse.AccountId = acc.Id;
        insert cse;
        
        RectifyDataEmailServiceClass rd = new RectifyDataEmailServiceClass();
        Messaging.InboundEmail msg = new Messaging.InboundEmail();
        msg.subject = 'Sandbox: '+con.Id;
        msg.plainTextBody = JSON.serialize(con);
        rd.handleInboundEmail(msg,null);
    }
}