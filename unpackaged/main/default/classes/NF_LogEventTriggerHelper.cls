public class NF_LogEventTriggerHelper {
	public static void handleAfterInsert(List<Log_Event__e> newList){
        try{
            List<Log__c> logList = new List<Log__c>();
            Set<String> fieldSet = new Set<String>();

            Log_Setting__mdt logSetting = [SELECT Field_Set__c 
                                            FROM Log_Setting__mdt 
                                                WHERE DeveloperName = 'Log_Setting'];

            if(String.isNotBlank(logSetting.Field_Set__c)){
                if(logSetting.Field_Set__c.contains(',')){
                    fieldSet.addAll(logSetting.Field_Set__c.replaceAll('(\\s+)', '').split(','));   
                } else {
                    fieldSet.add(logSetting.Field_Set__c);
                }
            }

            for(Log_Event__e logEvent: newList){
                Log__c log = new Log__c();
                log.ReplayId__c = logEvent.ReplayId;
                for(String fieldAPIName: fieldSet){
                    log.put(fieldAPIName,logEvent.get(fieldAPIName));
                }
                logList.add(log);
            }
            if(!logList.isEmpty()){
                insert logList;
            }
        } catch(Exception ex){
            Logger.logException(ex);
        }
    }
}