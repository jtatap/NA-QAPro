@isTest
public class ChildPrivacyCaseActionsHandlerTest {
  
    
    @TestSetup
    static void makeData(){
        List<Case> cseList=new List<Case>();
        Account acc = new Account();
        acc.Name = 'Calvin Klein';
        acc.Brand_Image_Link__c='https://help.calvinklein.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0683t000007znjd';
        acc.recordtypeid=Constants.brandRecordTypeId;
        insert acc;
        
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='2';
        con.System_Type__c = Constants.dataOwnerSupplemental; 
        con.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        con.DataOwner_Subtype__c = Constants.doNotSellorShare;
        insert con;
        
        
        Contact con1 = new Contact();
        con1.email = 'foo@example.com';
        con1.lastName = 'generic contact ' + Math.random();
        con1.AccountId = acc.id;
        con1.Brand_Id__c='2';
        con1.System_Type__c = Constants.dataOwnerSupplemental; 
        con1.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        insert con1;

        
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
        Case c = new Case(
            ContactId=con.Id,
            AccountId=acc.Id,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Sub_Type__c=Constants.doNotSellorShare,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c); 
        Case c5 = new Case(
            ContactId=con1.Id,
            AccountId=acc.Id,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Supplied_First_Name__c='Test',
            Sub_Type__c=Constants.doNotSellorShare,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c5); 
        
        Case c6 = new Case(
            ContactId=con1.Id,
            AccountId=acc.Id,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Supplied_First_Name__c='Test2',
            Sub_Type__c=Constants.rectifyRequestSubType,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c6); 
        
        Case c7 = new Case(
            ContactId=con1.Id,
            AccountId=acc.Id,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Supplied_First_Name__c='Test3',
            Sub_Type__c=Constants.accessRequestSubType,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c7);

      
        Case c1 = new Case(
            ContactId=con.Id,
            AccountId=acc.Id,
            Origin='Web',
            Brand__c='2',
            Status='Open',
            Sub_Type__c=Constants.rectifyRequestSubType,
           // Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c1); 
        
                Case c55 = new Case(
            ContactId=con1.Id,
            AccountId=acc.Id,
            Perfect_Match_Found__c=true,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Supplied_First_Name__c='Test5',
            Sub_Type__c=Constants.doNotSellorShare,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c55); 
        
        Case c66 = new Case(
            ContactId=con1.Id,
            AccountId=acc.Id,
            Perfect_Match_Found__c=true,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Supplied_First_Name__c='Test6',
            Sub_Type__c=Constants.rectifyRequestSubType,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c66); 
        
        Case c77 = new Case(
            ContactId=con1.Id,
            AccountId=acc.Id,
            Perfect_Match_Found__c=true,
            Origin='Web',
            Brand__c='2',
            Status='New',
            Supplied_First_Name__c='Test7',
            Sub_Type__c=Constants.accessRequestSubType,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        cseList.add(c77);
        insert cseList; 
        
         List<Case> cld=[select id from Case Limit 1];
        Case cls = new Case(
            ContactId=con.Id,
            AccountId=acc.Id,
            Origin='Web',
            parentid=cld[0].Id,
            Brand__c='2',
            Status='New',
            Sub_Type__c=Constants.doNotSellorShare,
            Supervisor_Data_Validation_Override__c = True,
            //Country_of_Residence__c='Canada',            
            //RecordTypeId=Constants.supportCaseRecordTypeId
           RecordTypeId=Constants.privacyRecordTypeId
        );
        insert cls;

    }        
         public static testmethod void getCsesTest()
          {
                List<Case> c = [SELECT Id,status,Sub_Type__c from Case Where ParentId=null and Brand__c ='2' LIMIT 1];
                test.startTest();
                if(c.size()>0){
                ChildPrivacyCaseActionsHandler.createChildDataOwnerCases(c[0].Id);
                c[0].Status='Open';
                update c[0];
                List<Case> cl = [SELECT Id,Sub_Type__c,ParentId from Case where ParentId!=null LIMIT 1];
               ChildPrivacyCaseActionsHandler.handleChildCaseResolved(cl[0].Id,c[0].Id); 
               
                List<Case> clo = [SELECT Id,Sub_Type__c,ParentId from Case where Supplied_First_Name__c='Test' LIMIT 1];
               ChildPrivacyCaseActionsHandler.updateParentCaseIfAllChildrenClosed(clo[0].Id); 
               
               List<Case> clo1 = [SELECT Id,Sub_Type__c,ParentId from Case where Supplied_First_Name__c='Test2' LIMIT 1];
               ChildPrivacyCaseActionsHandler.updateParentCaseIfAllChildrenClosed(clo1[0].Id);
               
               List<Case> clo2 = [SELECT Id,Sub_Type__c,ParentId from Case where Supplied_First_Name__c='Test3' LIMIT 1];
               ChildPrivacyCaseActionsHandler.updateParentCaseIfAllChildrenClosed(clo2[0].Id);

                test.stopTest();

               
                     }
                     }
    
     public static testmethod void getCsesTest1()
          {
                List<Case> c1 = [SELECT Id,Sub_Type__c from Case Where Brand__c ='2' LIMIT 1];
                test.startTest();
                if(c1.size()>0){
                ChildPrivacyCaseActionsHandler.createChildDataOwnerCases(c1[0].Id);
                     }
                                     List<Case> clo = [SELECT Id,Sub_Type__c,ParentId from Case where Supplied_First_Name__c='Test5' LIMIT 1];
               ChildPrivacyCaseActionsHandler.updateParentCaseIfAllChildrenClosed(clo[0].Id); 
               
               List<Case> clo1 = [SELECT Id,Sub_Type__c,ParentId from Case where Supplied_First_Name__c='Test6' LIMIT 1];
               ChildPrivacyCaseActionsHandler.updateParentCaseIfAllChildrenClosed(clo1[0].Id);
               
               List<Case> clo2 = [SELECT Id,Sub_Type__c,ParentId from Case where Supplied_First_Name__c='Test7' LIMIT 1];
               ChildPrivacyCaseActionsHandler.updateParentCaseIfAllChildrenClosed(clo2[0].Id);

                test.stopTest();
     }
}