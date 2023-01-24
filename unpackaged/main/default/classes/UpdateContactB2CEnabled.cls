global class UpdateContactB2CEnabled implements Database.Batchable <sObject>  {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( [select Id, B2C_Is_Enabled__c from contact where B2C_Is_Enabled__c = false AND Brand_ID__c = '2' AND Source_System__c = 'eComm' AND B2C_Customer_No__c != null]); //b2c customer number not null
    }
    global void execute(Database.BatchableContext bc, List<Contact> conList) {
        List<Contact> conToUpdate = new List<Contact>();
        for(Contact con: conList){
            con.B2C_Is_Enabled__c = true;
            conToUpdate.add(con);
        }
        database.update(conToUpdate, false); 
    }
	global void finish(Database.BatchableContext BC){} 
}