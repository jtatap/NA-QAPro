/*  Class: Batch_PurgeTrackerEvents
*  Description : Batch class to Delete TrackerEvents__c  records  with CreatedDate > (Today - 21)
*/

global class Batch_PurgeTrackerEvents implements Database.Batchable <sObject>, Database.Stateful {
    
    String QueryString = Null;
   // Static list<TrackerEvents__c> TrackerEvents = [select createdDate ,Id ,Type__c,Customer__c from TrackerEvents__c];
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
     system.debug('Started');
        
        QueryString = 'SELECT Id, CreatedDate,Type__c,Customer__c from TrackerEvents__c' ;
                      
        System.debug('QueryString: '+ QueryString);
        return Database.getQueryLocator(QueryString);
    }
    
    global void execute(Database.BatchableContext bc, List<TrackerEvents__c> records){
        system.debug('execute');
 
        List<TrackerEvents__c> TrackerEventsList = new List<TrackerEvents__c>();
        
        if (records != NULL && records.size()>0){
            system.debug('###### '+ records.size());  
            
            for(TrackerEvents__c T : records){
                system.debug('execute1');
                Date createdDate = date.valueOf(T.CreatedDate);
                system.debug('execute### '+ CreatedDate); 
                system.debug((createdDate.daysBetween(date.today())));
                
                //Checking condition For CreatedDate >Today() - 21
                if((createdDate.daysBetween(date.today()))> 21){
                    system.debug('inside if ');
                     TrackerEventsList.add(T);
                }
            }
        }
        
        System.debug('TrackerEvents List size: '+TrackerEventsList.size());
        
        if(TrackerEventsList.size()>0){
            List<database.DeleteResult> results = Database.delete(TrackerEventsList,false);
            
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
        system.debug('finish');
    }
}