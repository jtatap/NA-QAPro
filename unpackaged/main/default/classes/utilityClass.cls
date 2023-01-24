public class utilityClass {
    
    public static DateTime convertISO8601(String iso8601_ts)
    {
        DateTime dt = (DateTime) JSON.deserialize(
            '"' + iso8601_ts + '"', DateTime.class);
        return DateTime.newInstance( dt.getTime());                            
    }
    
    public static Date strYYYMMDDtoDate(String strDate){
        //TODO this should verify that the string is the correct length.
        if(String.isBlank(strDate)) {
            return null;
        }
        if(strDate.contains('T')) {
            return Datetime.valueOf(strDate.replace('T',' ')).date();
        } 
        Integer year, month, day;
        year = Integer.valueOf(strDate.left(4));
        month = Integer.valueOf(strDate.substring(4,6));
        day = Integer.valueOf(strDate.right(2));
        
        Date dtime = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        return dtime;
        
    }
    
    public static DateTime strYYYMMDDtoDateTime(String strDateTime){
        
        if(strDateTime.contains('T')) {
            return convertISO8601(strDateTime);
        }
        else if (strDateTime.length()==8) {
            
            Integer year, month, day;
            year = Integer.valueOf(strDateTime.left(4));
            month = Integer.valueOf(strDateTime.substring(4,6));
            day = Integer.valueOf(strDateTime.right(2));
            
            DateTime dtime = DateTime.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
            System.debug('**'+dtime);
            return dtime;
        }
        else return system.now();
        
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr ='';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    
    public static Boolean triggerEnabled(String className){
        // List<Profile> usersProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        if(!Test.isRunningTest()){
            Map<id,Profile> usersProfileMap=new Map<id,Profile>([Select Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() limit 1]);
            List<Profile> usersProfile = usersProfileMap.values() ;  
            String myProfileName='';
            if(usersProfile.size() == 0) {
                return true;
            }
            /* for(Profile userpro:usersProfile){
myProfileName = userpro.Name;
}*/
            myProfileName = usersProfile[0].Name;
            String myUserName = UserInfo.getUserName();
            List<String> metadataKeys = new List<String>();
            metadataKeys.add(myUserName + '|' + className); //UserName & Trigger combo override
            metadataKeys.add(myProfileName + '|' + className); //Profile & Trigger combo override
            metadataKeys.add('*|' + className); //Trigger level override
            metadataKeys.add(myProfileName + '|*'); //Profile level override
            metadataKeys.add(myUserName + '|*'); //UserName level override
            metadataKeys.add('*|*'); //Global override
            
            
            List<TriggerFactoryOverride__mdt> tfo =new  List<TriggerFactoryOverride__mdt>();
            
            //We only need to find one match that has Disable checked to skip the trigger
            if(metadataKeys.size() > 0){
                tfo = [SELECT DisableTrigger__c 
                       FROM TriggerFactoryOverride__mdt 
                       WHERE ProfileTrigger__c = :metadataKeys AND DisableTrigger__c = true 
                       LIMIT 1];
            }
            
            if (tfo.size() > 0) {
                //System.debug('Skip trigger execution because override found in TriggerFactoryOverride__mdt');
                return false;
            }
        }
        return true;
        
    }
    
    public static Boolean triggerEnabled(Type classType) {
        return triggerEnabled(classType.getName());
    }
    
    public static map<string,string> getPicklistValues(string objName,string fieldName){
        map<string,String> mapPicklistValues= new map<string,String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(!mapPicklistValues.containskey(pickListVal.getvalue()) && pickListVal.isActive()){
                mapPicklistValues.put(pickListVal.getvalue(),pickListVal.getLabel());
            }
        }    
        system.debug('mapPicklistValues'+mapPicklistValues);
        
        return mapPicklistValues;
    }
    
    
}