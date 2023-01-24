/* Jira No : NASSC-3317
  * Class: Batch_deleteextracttarget
*  Description : Batch class to Delete  bh.extracttarget.com Contacts	Records with CreatedDate > (Today - 6 Months)
*/

global class Batch_deleteextracttarget implements  Database.Batchable <sObject>{
 
    String QueryString = Null;
    String searchKeyword  = '@bh.extracttarget.com';
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        QueryString ='SELECT Id,Email,CreatedDate FROM Contact where Email LIKE \'%' +searchKeyword+'%\'';
        System.debug('QueryString: '+ QueryString);
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> records){
         List<Contact> bhExtractList = new List<Contact>();
            
        
        for(Contact  con: records){
            date createddate = date.valueOf(con.CreatedDate);
            date today = date.valueOf(system.now());
            integer datediff = CreatedDate.daysBetween(Today);
            system.debug('** Inside logic');
            
            if(con.Email.CONTAINS('@bh.extracttarget.com')){
                system.debug('** Email'+con.Email);
              if(datediff > 1){  
              bhExtractList.add(con);
            
              }
			}
        } 
            
        
        System.debug('bhExtractList size: '+ bhExtractList.size());
        
        if(bhExtractList.size()>0){
            List<Database.DeleteResult> results = Database.Delete(bhExtractList, false);
            for (Database.DeleteResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                        System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                    }
                }
            }
        } 
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}