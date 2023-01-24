@isTest
public class ReasonCodeButtonConrollerTest {
    
   @isTest
     static void TestButtonControllerMethod ()
    {
        
        List<string> reasonManufaList=new List<string>();
        Account acc = new Account();
        acc.Name = 'generic Account' + Math.random();
        insert acc;
        
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='9';
        insert con;

        
        Case parentcse = new Case();
        parentcse.ContactId=con.Id;
        parentcse.AccountId=acc.Id;
        parentcse.Origin='Email';
        parentcse.Brand__c='2';
        parentcse.Status='Open';
        parentcse.RecordTypeId=Constants.supportCaseRecordTypeId;
        parentcse.Reason_Code__c = 'hy';
        parentcse.Reason_Code_Details__c = 'khy';
        parentcse.Reason_Sub_detail__c = 'nothing';
        insert parentcse ;
        
        Case cse = new Case();
        cse.ParentId=parentcse.id;
        cse.Brand__c='9';
        cse.ContactId=con.Id;
        cse.AccountId=acc.Id;
        cse.RecordTypeId=Constants.supportCaseRecordTypeId;
        insert cse ;
        
        
        cse.Reason_Code__c = 'Corporate';
        cse.Reason_Code_Details__c = 'Human Resource';
        cse.Reason_Sub_detail__c = 'nothing';
        cse.ZdPVHDateofServiceIssue__c = date.today();
        cse.ZdPVHStoreNumber__c = '58';
        cse.ZdPVHDistrictNumber__c = '345';
        cse.ZdPVHUpdateAccountInfoReason__c = 'poor';
        cse.ZdPVHManufacturer__c='Test';
        cse.ZdPVHProductCategory__c='Test';
        cse.Reason_Code_Manufacturers__c='Test1';
        cse.Reason_Code_Product_Category__c = 'test2';
        cse.Sku_Style_Number__c='45';
        cse.Reason_Code_Product_Sub_Categories_Widge__c='testing';
        cse.Third_Party_Vendors__c='testing vendors';
         update cse ;
        
        Case cse1 = new Case();
        cse1.ParentId=parentcse.id;
        cse1.Brand__c='11';
        cse1.ContactId=con.Id;
        cse1.AccountId=acc.Id;
        cse1.RecordTypeId=Constants.supportCaseRecordTypeId;
         insert cse1 ;
        cse1.TrueAndCo_ReasonCodes__c='Testing True & Co';
        cse1.TrueAndCo_ReasonCodeDetails__c='Testing True & Co';
        cse1.TrueAndCo_ReasonSubDetail__c='Testing True & Co';
        cse1.Reason_Code__c = 'Corporate';
        cse1.Reason_Code_Details__c = 'Human Resource';
        cse1.Reason_Sub_detail__c = 'nothing';
        cse1.Channel__c='channel';
        cse1.Sku_Style_Number__c='45';
       
        update cse1;
       
        
        
        
        String recordId = cse.id;
        String grandParent = cse.Reason_Code__c;
        String parentField = cse.Reason_Code_Details__c;
        String childField = cse.Reason_Sub_detail__c;
        date dateofServiceIssue = date.today();
        String storeNumber = cse.ZdPVHStoreNumber__c ;
        String districtNumber = cse.ZdPVHDistrictNumber__c;
        String updateAccountInfoReason = cse.ZdPVHUpdateAccountInfoReason__c ;
        string manufacturer= cse.ZdPVHManufacturer__c;
        string productCategory=cse.ZdPVHProductCategory__c;
        string reasonManu=cse.Reason_Code_Manufacturers__c;
        string skuNumber=cse.Sku_Style_Number__c;
        string prosubCat=cse.Reason_Code_Product_Sub_Categories_Widge__c;
        string thirdPartyVen=cse.Third_Party_Vendors__c;
        String trueGrandParent = cse1.TrueAndCo_ReasonCodes__c;
        String trueParentField = cse1.TrueAndCo_ReasonCodeDetails__c;
        String trueChildField = cse1.TrueAndCo_ReasonSubDetail__c;
        String trueGrandParent1 = cse1.Reason_Code__c ;
        String trueParentField1 = cse1.Reason_Code_Details__c;
        String trueChildField1 = cse1.Reason_Sub_detail__c;
       
        String channel= cse1.Channel__c;
        String placeOfPurchase=cse1.Place_of_Purchase__c;
            reasonManufaList.add(reasonManu);
      
        
        string contrfieldApiName=cse.Reason_Code__c;
        string depfieldApiName=cse.Reason_Code_Details__c;
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        integer val=10;
        string validFor1='test';
        string active='true';
        String defaultValue='test';
        String value='testing';
        Map<String, List<String>> lstPick1=ReasonCodeButtonController.getDependentPicklist(cse,'Reason_Code__c','Reason_Code_Details__c');
       //List <String> selectOpManu=ReasonCodeButtonController.getselectOptions(cse,cse.Reason_Code_Manufacturers__c);
       //List<String> lstString = ReasonCodeButtonController.getselectOptions(cse , 'reasonManu');
     

       Test.starttest();
         //List <String> selectManu=ReasonCodeButtonController.getselectOptions(cse,'reasonManu');
        
        List<Case> result = ReasonCodeButtonController.updateCase(recordId ,grandParent, prosubCat, parentField, childField , dateofServiceIssue,  storeNumber ,districtNumber, updateAccountInfoReason, manufacturer, productCategory,skuNumber,thirdPartyVen);
         List<Case> trueNcoResult = ReasonCodeButtonController.trueNcoUpdateCase(recordId ,trueGrandParent, trueParentField, trueChildField, skuNumber,channel,placeOfPurchase);
           string decimalToBinary=ReasonCodeButtonController.decimalToBinary(val);
           string base64ToBits=ReasonCodeButtonController.base64ToBits(validFor1);
           ReasonCodeButtonController.PicklistEntryWrapper testWrapper = new ReasonCodeButtonController.PicklistEntryWrapper(); 
              active =testWrapper.active;
              defaultValue =testWrapper.defaultValue;
              String label =testWrapper.label;
               value =testWrapper.value;
              String validFor =testWrapper.validFor;
             
           
           Map<String, List<String>> picklistValues=ReasonCodeButtonController.getDependentPicklist(cse,contrfieldApiName,depfieldApiName );
             List<String> selectionoptions = ReasonCodeButtonController.getselectOptions(cse , 'Reason_Code_Product_Category__c' );
            
        Test.stopTest() ;
        
        
    }
    
   
        
    

}