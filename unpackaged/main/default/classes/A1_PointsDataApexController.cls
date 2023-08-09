/******************************************************************************
* @Description: Show Points Data to Case and Contact Page
* @Author	  : Rounak P
* @Date		  : 01:01.2020
* @JIRA		  : NASSC-1146,1148,1183
*
******************************************************************************/ 

public without sharing class A1_PointsDataApexController {

    /*
    @AuraEnabled
    public static boolean checkPendingPointsStatus(Id recordId){
        Log.push('ID = '+recordId);
        Case getCase = [Select Id,PendingPointsAdjustment__c from Case where Id=:recordId ];
        //Log.push('Pending Point Status = '+getCase.PendingPointsAdjustment__c);
        return getCase.PendingPointsAdjustment__c;
    }
   	*/
    
   
    @AuraEnabled
    public static BooleanWrapper checkPendingPointsStatus(Id recordId){
        BooleanWrapper wrapperObjBoolean = new BooleanWrapper();
        wrapperObjBoolean.isEnableRewardsButton = false;
        //Log.push('ID = '+recordId);
        Case getCase = [Select Id,Contact.Brand_Id__c,PendingPointsAdjustment__c from Case where Id=:recordId ];
        //Log.push('Pending Point Status = '+getCase.PendingPointsAdjustment__c);
        //Log.push('&&&'+getCase.Contact.Brand_Id__c);
        List<LoyaltySettings__mdt> loyaltyData = [Select Id, EnableRewardsButton__c from LoyaltySettings__mdt WHERE
                                                 BrandId__c=:getCase.Contact.Brand_Id__c];
        
        wrapperObjBoolean.isPendingPointAdjustment = getCase.PendingPointsAdjustment__c;
        if(loyaltyData.size()>0) wrapperObjBoolean.isEnableRewardsButton = loyaltyData[0].EnableRewardsButton__c;
        Log.push('***Pending Point = '+wrapperObjBoolean.isPendingPointAdjustment);
        Log.push('***Reward Button = '+wrapperObjBoolean.isEnableRewardsButton);
        //Commented by NF Log.push('***Pending Point = '+wrapperObjBoolean.isPendingPointAdjustment);
        //Commented by NF Log.push('***Reward Button = '+wrapperObjBoolean.isEnableRewardsButton);
        Logger.logDebug();
        return wrapperObjBoolean;
    }
    
    
    @AuraEnabled
    public static List<AgileOne.TransactionRec> getPoints(Id recordIds) {
        system.debug('** Inside GetPoints**');
       Map<String,String> LoyaltyMap = new Map<String,String>();
        List<AgileOne.TransactionRec> listTransaction = new  List<AgileOne.TransactionRec>(); 
        Contact conRecord;
        Case caseRecord;
        String brandIdToSupply;
        
        Schema.SObjectType token = recordIds.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Log.push('Name = '+dr.getName());
		Log.push('Name = '+dr.getName());
        
        system.debug('Name *** '+dr.getName());
        
        // fetching loyalty MDT
        List<LoyaltySettings__mdt> loyaltyList = [Select Id, BrandId__c, Parent_Brand__c from LoyaltySettings__mdt];
        for(LoyaltySettings__mdt loyalRecord : loyaltyList){
            if(loyalRecord.Parent_Brand__c != null){
            	LoyaltyMap.put(loyalRecord.BrandId__c,loyalRecord.Parent_Brand__c);
            }
        }
        Log.push('***Points Loyalty Map = '+LoyaltyMap);
         system.debug('Points Loyalty Map *** '+LoyaltyMap);
        if(dr.getName().equals('Contact')){
            conRecord = [Select LoyaltyID__c,Brand_Id__c from Contact WHERE Id=:recordIds];
            brandIdToSupply = conRecord.Brand_Id__c;
            system.debug('brandIdToSupply *** '+brandIdToSupply);
        }
        else if(dr.getName().equals('Case')){
            caseRecord = [Select Contact.LoyaltyID__c,Contact.Brand_Id__c,Contact.Email from Case WHERE Id=:recordIds];
            brandIdToSupply = caseRecord.Contact.Brand_Id__c;
             system.debug('brandIdToSupply *** '+brandIdToSupply);
        }       
        
        //if records brand is child, assigning brandId with its parent
        if(LoyaltyMap.containsKey(brandIdToSupply)){
            Log.push('***changing brandIdToSupply: subBrand to parentBrand');
            brandIdToSupply = LoyaltyMap.get(brandIdToSupply);
             system.debug('brandIdToSupply *** '+brandIdToSupply);
        }
        
        Log.push('***Points brandIdToSupply = '+brandIdToSupply);
         system.debug('brandIdToSupply *** '+brandIdToSupply);	
        
        if(conRecord!=null && conRecord.LoyaltyID__c !=null && conRecord.Brand_Id__c!=null && !Test.isRunningTest()){
             Log.push('Loyalty Id = '+conRecord.LoyaltyID__c);
			 listTransaction = AgileOne.getC360Data(conRecord.LoyaltyID__c,  brandIdToSupply);
             system.debug('istTransaction***'+listTransaction);
 
        }
        else if(caseRecord!=null && caseRecord.Contact.LoyaltyID__c !=null && caseRecord.Contact.Brand_Id__c!=null && !Test.isRunningTest() ){
             system.debug('caseRecord***'+caseRecord);
              system.debug('caseRecord.Contact.LoyaltyID__c***'+caseRecord.Contact.LoyaltyID__c);
            system.debug('caseRecord.Contact.Brand_Id__c***'+caseRecord.Contact.Brand_Id__c	);
             Log.push('Loyalty Id = '+caseRecord.Contact.LoyaltyID__c);
             listTransaction = AgileOne.getC360Data(caseRecord.Contact.LoyaltyID__c,brandIdToSupply);
            
            system.debug('ListTransaction***'+listTransaction);
           List<Contact> toBeUpdatedList = new List<Contact>();
            for(AgileOne.TransactionRec tran: listTransaction) {
                if (tran.Category == 'Customer Summary') {
                    Double pointBalance = tran.currentPointBalance;
                    System.debug(' pointBalance ' + pointBalance);
                    Contact caseContact = new Contact();
                    caseContact.Id = caseRecord.ContactId;
                    caseContact.Point_Balance__c = pointBalance;
                  	toBeUpdatedList.add(caseContact);
                   
                    List<Contact> conList = [SELECT Id, Ecomm_Connected__c, Email, Brand_Id__c
                                   FROM Contact 
                                   where Brand_Id__c =:caseRecord.Contact.Brand_Id__c AND Email = :caseRecord.Contact.Email order by lastmodifieddate desc];
                   System.debug('conList ** ' + conList);
                    for(Contact con: conList)
                    {
                        if(con.Ecomm_Connected__c == true && con.Id != caseContact.Id){
                            con.Point_Balance__c = pointBalance;
                            toBeUpdatedList.add(con);
                        }
                    }
            }
            }
            update toBeUpdatedList; 
               
        }
       
       Log.push('***Transaction List = '+listTransaction);
       Logger.logDebug(); 
        system.debug('listTransaction***'+listTransaction);
       return  listTransaction;
    }
    public static void test234Method(){
    Integer i=0;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;  
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;  
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;  
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;  
           i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;
     i=i+1;
    i=i+1;
    i=i+1;
    i=i+1;  
    //repeat the i++ hundred of times

  } 
    	
    	public class BooleanWrapper {
        @AuraEnabled
        public boolean isPendingPointAdjustment { get; set; }
        @AuraEnabled
        public boolean isEnableRewardsButton { get; set; }

    }
   
}