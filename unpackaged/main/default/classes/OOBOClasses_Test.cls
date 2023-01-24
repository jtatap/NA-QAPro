@isTest
public class OOBOClasses_Test {
	static testmethod void contactCheck_Test(){
               
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',Brand_Id__c = '1'
                                  ,B2C_Is_Enabled__c=false,B2C_Is_Locked__c=true,LoyaltyID__c='TH4005373229');
        insert con;
        GenericRecords__c gr = new GenericRecords__c();
        gr.recordId__c = con.Id;
        gr.Name ='privacyContact';
        insert gr;
        case cs =new case(Type='Support',Status='New',SuppliedEmail='test@gmail.com',Brand__c='1');
        insert cs;
        ContactCheck.getContactId(cs.Id);
        cs.ContactId = con.Id;
        update cs;
        ContactCheck.getContactId(cs.Id);  
        con.B2C_Is_Enabled__c = true;
        update con;
        ContactCheck.getContactId(cs.Id);
		con.B2C_Is_Locked__c=false;
        update con;
		ContactCheck.getContactId(cs.Id);  
        ContactCheck.eCommConnectedFlag(con.Id);
        con.Ecomm_Connected__c = true;
        con.B2C_Customer_No__c ='12345678';
        update con;
        ContactCheck.eCommConnectedFlag(con.Id);
        ContactCheck.eCommOtherCont (con.Id);
        
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        ContactCheck.linkContact (cs.Id,conList);
    }   
}