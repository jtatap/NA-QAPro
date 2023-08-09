@isTest
public class CSRchanges_Test {
    
    static testmethod void getContact_Test(){
               
        account acc = new account(name = 'DummyAccount');
        insert acc;
        
        contact con = new contact (lastname='Dummycontact' ,email='test@gmail.com',Brand_Id__c = '2');
        insert con;
        getContact.getContactDetails(con.Id);
        GenericRecords__c gr = new GenericRecords__c();
        gr.recordId__c = con.Id;
        gr.Name ='privacyContact';
        insert gr;
        case cs =new case(Type='Support',Status='New',SuppliedEmail='test@gmail.com',ContactId=con.id,Brand__c='2');
        insert cs;
        con.Ecomm_Connected__c = true;
        con.B2C_Customer_No__c ='12345678';
        update con;
        
        
        //Case CS = new Case();
        //CS.contactId = C.Id;
        //CS.Brand__c = '2';
        //insert CS;
        
        getContact.getContactDetails(con.Id);
        getContact.getOldMail(con.Id);
        getContact.searchMail(con.Email);
        Test.startTest();
        getContact.updateCSREmailField(con.Id,con.Email);

        
        List<Case> Ca = [select Id, Brand_Lookup_Search__c,ContactEmail,contactId from Case where Id =:cs.Id];
        mailChangeRequest.mailChangeRequest(Ca);
        
 	    cs.CSRMailUpdateonContact__c = true;
        cs.VerificationHash__c ='WwwtS4KRmST3gBYN';
        //cs.LastModifiedById = '0051U000006XWVd';
        update cs;
        
 //////////UpdateContactEmailBack --Test       
        con.OldEmail__c = con.email;
        update con;
        ////
        B2CIAValidateContactInput contactInput;
        Database.SaveResult output;
        String jsonString;
        B2C_CustomerList__c tmpCustomerList;
        Boolean threwException;

        // Initialize the input property
        contactInput = new B2CIAValidateContactInput();

        // Default the exception flag
        threwException = false;

        // Define the b2cInstance
        contactInput.b2cInstance = new B2C_Instance__c(
            Name = 'INST',
            API_Url__c = 'https://www.salesforce.com',
            Is_Active__c = true
        );

        Database.insert( contactInput.b2cInstance );

        // Define the customerList
        contactInput.customerList = new B2C_CustomerList__c(
            B2C_Instance__c = contactInput.b2cInstance.Id,
            Name = 'My CustomerList',

            // Include a malformed url (expecting '/s/') to force the baseUrl formula to fail
            API_Url__c = 'https://www.salesforce.com',
            Enable_Profile_Retrieval__c = true,
            Enable_Profile_Publishing__c = true,
            Enable_Profile_Creation__c = true,
            Enable_Profile_Updates__c =true,
            Is_Active__c = true,
            OCAPI_Version_No__c = 'v20_10'
        );

        Database.insert( contactInput.customerList );

        
        
        B2C_Contact_Integration_History__c b2cHist = new B2C_Contact_Integration_History__c(
        												 Contact__c=con.Id,
        												 B2C_CustomerList__c=contactInput.customerList.Id,
            											 Integration_JSON__c = '{  "fault" : {    "message" : "The login name is already in use.",    "type" : "LoginAlreadyInUseException"  },  "_v" : "21.3"}'
        													);
        Database.insert(b2cHist);
        list<Id> b2cHistList = new list<Id>();
        b2cHistList.add(b2cHist.Id);
        UpdateContactEmailBack.updateEmail(b2cHistList);

        ///////API Class 
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://privacyCSR?in_response=Open&in_verificationCode=WwwtS4KRmST3gBYN&in_caseid='+cs.Id;
    
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{"in_caseid":'+cs.Id+ ',"in_response":"Open","in_verificationCode":"Yes"}');
        req.params.put('in_caseid',cs.Id);
        req.params.put('in_response','Open');
        req.params.put('in_verificationCode',cs.VerificationHash__c);
        RestContext.request = req;
        RestContext.response= res;
	    PrivacyEmailChange_ProcessResponse_API.restGet();

        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://privacyCSR?in_response=Open&in_verificationCode=WwwtS4KRmST3gBYN&in_caseid='+cs.Id;
    
        req2.addHeader('Content-Type', 'application/json');
        req2.httpMethod = 'GET';
        req2.requestBody = Blob.valueof('{"in_caseid":'+cs.Id+ ',"in_response":"Open","in_verificationCode":"Yes"}');
        req2.params.put('in_caseid',cs.Id);
        req2.params.put('in_response','Resolved');
        req2.params.put('in_verificationCode',cs.VerificationHash__c);
        RestContext.request = req2;
        RestContext.response= res2;
	    PrivacyEmailChange_ProcessResponse_API.restGet();

        
        ///eMailServiceCSRMail
 		eMailServiceCSRMail emailService = new eMailServiceCSRMail();
 		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Sandbox: '+cs.Id;
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Test';
        
        emailService.handleInboundEmail(email,env);
                Test.stopTest();
        
    }
}