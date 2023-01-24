public class ChildCaseController {

     @AuraEnabled
        public static List<Case> getCases(String recordID){
            Id myId = UserInfo.getUserId();
            System.debug('myId+++++++++++'+myId);
        
            List<Case> clist = [Select Id, Subject,ContactId,Type, Origin, Status,Brand__c,Contact_Loyalty_ID__c From Case where ID =:recordID ];
        
            System.debug('clist++++++++++'+cList.size());
            return cList;
        }

   
       /* public static Case saveCase(String caseJSON) {
            system.debug('inside SaveCase');
            Case newCase = (Case)JSON.deserialize(caseJSON, Case.class);
        
            upsert newCase;
            return newCase;
        }*/
        @AuraEnabled
    public static List<Case> saveCase(String recordId ,String subjectField,String statusField,String descField,String contactField) {
        system.debug('Inside saveCase****'+contactField);
        
        list<Case> caseList = new list<Case>();
        List<Case> exisCaseList=[Select Id,NFCaseScenario__c,Brand__c,SuppliedName,Reason_Code_Product_Category__c,Reason_Code_Product_Sub_Categories_Widge__c,ZdPVHUpdateAccountInfoReason__c,Third_Party_Vendors__c,Reason_Code_Product_Sub_Categories__c,ZdPVHDateofServiceIssue__c,ZdPVHDistrictNumber__c,SuppliedEmail,ZdPVHStoreNumber__c,Reason_Code_Manufacturers__c,SuppliedPhone, NFCaseScenario__r.NFScenarioCategory__c, NFCaseScenario__r.NF_Scenario__c, Channel__c,Origin from Case where Id =: recordId];
        List<Contact> conList=[Select Id,Brand_ID__c from Contact where Id =: contactField];
        system.debug('Inside saveCase conList****'+conList);
        string brand;
        string name;
        string email;
        string phone;
            string caseScenario;
        //string reasonCode;
        //string reasonCodeDetails;
        string channel;
        string origin;
        string updateAccountreasonInfo;
        string reasonCodemanufactures;
        string reasonCodeProductCategory;
        string storeNumber;
        string districtNumber;
        string dateOfServiceissue;
        string reasonCodeProdSubCat;
        string thirdPartyVendors;
        /* for(Contact con:conList){
brand=con.Brand_ID__c;
} */
        for(Case cas:exisCaseList){
            brand=cas.Brand__c;
            name=cas.SuppliedName;
            email=cas.SuppliedEmail;
            phone=cas.SuppliedPhone;
            caseScenario = cas.NFCaseScenario__c;
           // reasonCode=cas.Reason_Code__c;
            //reasonCodeDetails=cas.Reason_Code_Details__c;
            channel=cas.Channel__c;
            origin='Phone';
            updateAccountreasonInfo=cas.ZdPVHUpdateAccountInfoReason__c;
            reasonCodemanufactures=cas.Reason_Code_Manufacturers__c;
            reasonCodeProductCategory=cas.Reason_Code_Product_Category__c;
            storeNumber=cas.ZdPVHStoreNumber__c;
            districtNumber=cas.ZdPVHDistrictNumber__c;
            dateOfServiceissue=string.valueof(cas.ZdPVHDateofServiceIssue__c);
            reasonCodeProdSubCat=cas.Reason_Code_Product_Sub_Categories_Widge__c;
            thirdPartyVendors=cas.Third_Party_Vendors__c;
        } 
        Case cse=new Case();
        cse.Subject=subjectField;
        cse.Status=statusField;
        cse.Description=descField;
        cse.ContactId=contactField;
        cse.Brand__c=brand;
        cse.SuppliedName=name;
        cse.SuppliedEmail=email;
        cse.SuppliedPhone=phone;
        cse.ParentId=recordId;
        cse.IsChild__c=true;
            cse.NFCaseScenario__c = caseScenario;
      //  cse.Reason_Code__c=reasonCode;
       // cse.Reason_Code_Details__c=reasonCodeDetails;
        cse.Channel__c=channel;
        cse.Origin=origin;
        cse.ZdPVHUpdateAccountInfoReason__c=updateAccountreasonInfo;
        cse.Reason_Code_Manufacturers__c=reasonCodemanufactures;
        cse.Reason_Code_Product_Category__c=reasonCodeProductCategory;
        cse.ZdPVHStoreNumber__c=storeNumber;
        cse.ZdPVHDistrictNumber__c=districtNumber;
        if(string.isNotEmpty(dateOfServiceissue)){
        cse.ZdPVHDateofServiceIssue__c=date.valueof(dateOfServiceissue);
        }
        cse.Reason_Code_Product_Sub_Categories_Widge__c=reasonCodeProdSubCat;
        cse.Third_Party_Vendors__c=thirdPartyVendors;
        if(cse.Subject !=Null || cse.Status !=Null || cse.Description !=Null || cse.ContactId !=Null
           || cse.ParentId !=Null || cse.Brand__c!=Null ||  cse.SuppliedName!=Null ||  cse.SuppliedEmail!=Null
           || cse.SuppliedPhone!=Null || cse.NFCaseScenario__c != Null || cse.Channel__c!=Null
           || cse.Origin!=Null
          ){
              caseList.add(cse);
          }
        if(caseList.size()>0){
            insert caseList;
        }
        system.debug('Inside saveCase****'+caseList);
        return caseList;
    }
    
}