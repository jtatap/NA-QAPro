global class UpdateContactLoyaltyPoints implements Database.Batchable <sObject>, Database.stateful  {
    //private List<ExceptionCSVAttributes> exceptionCSVAttributesList = new List<ExceptionCSVAttributes>();
    private List<Contact> conList = new List<Contact>();
    private String linkEntId;
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( [SELECT Id, IsProcessed__c, Brand_ID__c, Point_Balance__c, Loyalty_ID__c 
                                          FROM ContactStaging2__c WHERE IsProcessed__c = false AND ForPointBalance__c  = true]); 
    }
    global void execute(Database.BatchableContext bc, List<ContactStaging2__c> conStgList) {
        List<Contact> conToUpdate = new List<Contact>();
        Map<String, Decimal> loyaltyPointsMap = new Map<String, Decimal>();
        linkEntId = conStgList[0].Id;
        //Map<String, String> loyaltyException = new Map<String, String>();
        for(ContactStaging2__c conSrg: conStgList){
            loyaltyPointsMap.put(conSrg.Loyalty_ID__c , conSrg.Point_Balance__c);
        }
        
        //List<Contact> conList1 = [SELECT Id,Brand_Id__c, Point_Balance__c, LoyaltyID__c FROM Contact WHERE LoyaltyID__c =: loyaltyPointsMap.keyset() AND Brand_ID__c = '2'];
        for(Contact con: [SELECT Id,Brand_Id__c, Point_Balance__c, LoyaltyID__c FROM Contact WHERE LoyaltyID__c =: loyaltyPointsMap.keyset() AND Brand_ID__c = '2']){
            con.Point_Balance__c = loyaltyPointsMap.get(con.LoyaltyID__c);
            conList.add(con);
        }
        //conList.addAll(conList1);
       /* for(Contact con: [SELECT Id, Point_Balance__c, LoyaltyID__c FROM Contact WHERE LoyaltyID__c =: loyaltyPointsMap.keyset() AND Brand_ID__c = '2']){
            con.Point_Balance__c = loyaltyPointsMap.get(con.LoyaltyID__c);
            conToUpdate.add(con);
        }
        
        Database.SaveResult [] updateResult = Database.update(conToUpdate, false);
		for (Database.SaveResult result : updateResult){
        	if (!result.isSuccess()){
            	for (Database.Error error : result.getErrors()){
                    ExceptionCSVAttributes eca = new ExceptionCSVAttributes();
                    eca.fields = error.getFields();
                    eca.errorMessage = error.getMessage();
                	exceptionCSVAttributesList.add(eca);
            	}
            }
        }*/
        List<ContactStaging2__c> conStgListToUpdate = new List<ContactStaging2__c>();
        for(ContactStaging2__c constg: conStgList){
            constg.IsProcessed__c = true;
            conStgListToUpdate.add(constg);
        }
        Database.update(conStgListToUpdate, false);
    }
	global void finish(Database.BatchableContext BC){
        
        string header = 'Sub_Key,Brand_Id__c,Point_Balance__c,LoyaltyID__c\n';
        string finalstr = header;
        for(Contact c: conList){
            string recordString = c.id+','+c.Brand_Id__c+','+c.Point_Balance__c+','+c.LoyaltyID__c+'\n';            
            finalstr = finalstr +recordString;
        }
        /*string header = 'Fields,ErrorMessage\n';
        string finalstr = header;
        for(ExceptionCSVAttributes e: exceptionCSVAttributesList){
            string recordString = e.fields+e.errorMessage+'\n';            
            finalstr = finalstr +recordString;
        }*/
        ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf(finalstr);
            ContVerFile.Title = 'RecordsForLoyaltyPoints.csv'; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient='RecordsForLoyaltyPoints';
        insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = linkEntId;
            cDe.ShareType = 'I';
            cDe.Visibility = 'AllUsers';
            insert cDe;
    }
    
    /*global class ExceptionCSVAttributes{
        public List<String> fields;
        public String errorMessage; 
    } */
}