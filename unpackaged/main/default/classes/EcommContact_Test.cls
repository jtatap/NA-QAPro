@isTest
public class EcommContact_Test {

    static testmethod void OOBOTest(){
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',Brand_Id__c = '1',LoyaltyID__c='123456');
        insert con;
        
        getContact.getContactDetails(con.Id);
        GenericRecords__c gr = new GenericRecords__c();
        gr.recordId__c = con.Id;
        gr.Name ='privacyContact';
        insert gr;
        case cs =new case(Type='Support',Status='New',SuppliedEmail='test@gmail.com',Brand__c='1');
        insert cs;
        ecommContactCase.getContactId(cs.Id);
        cs.ContactId=con.id;
        update cs;
        ecommContactCase.getContactId(cs.Id);
        ecommContactCase.eCommConnectedFlag(con.Id);
        
        con.Ecomm_Connected__c = true;
        con.B2C_Customer_No__c ='12345678';
        update con;
        ecommContactCase.eCommConnectedFlag(con.Id);
        
        
        con.Ecomm_Connected__c = false;
        con.B2C_Customer_No__c = '';
        update con;
        ecommContactCase.getContactId(cs.Id);
        //ecommContactCase.eCommOtherCont(con.Id);
        
        contact cont = new contact (lastname='Dummycontact' ,email='test@gmail.com',Brand_Id__c = '1',LoyaltyID__c='123456',Ecomm_Connected__c = true,B2C_Customer_No__c ='12345678');
        insert cont;
        list<contact> conList = new list<contact>();
        conList.add(cont);
        ecommContactCase.eCommOtherCont(con.Id);
        ecommContactCase.linkContact(cs.Id,conList);
        
        
    }
}