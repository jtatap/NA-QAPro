trigger ContactTrigger on Contact (before insert, before update,before delete,after update, after insert, after delete, after undelete) {
    
    String ptformIntUser = System.Label.PlatformIntegrationUser;
    map<string,SubscriberDataSources__mdt>mapDataSource=new map<string,SubscriberDataSources__mdt>();
    List<SubscriberDataSources__mdt> listDataSource = [SELECT Brand__c, SourceSystem__c, 
                                                       WelcomeSource__c,DataSource__c
                                                       FROM SubscriberDataSources__mdt];
    if(listDataSource.size()>0){
        for(SubscriberDataSources__mdt objData:listDataSource){
            string brandandWelcomeSource=objData.Brand__c+objData.WelcomeSource__c;
            if(!mapDataSource.containskey(brandandWelcomeSource) && string.isNotBlank(brandandWelcomeSource)){
                mapDataSource.put(brandandWelcomeSource,objData);
            }  
        }
    }
    //Map for Pointbalance info for Mulesoft fix
	Map<Id, Decimal> pointBalenceMap = new Map<Id, Decimal>();
    If(UserInfo.getLastName()!=ptformIntUser && UserInfo.getName()!='System' && UserInfo.getName()!='Automated Process'){
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        List<User> userList = [SELECT Id,Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        String userName=userList[0].Name;
        String profileName=profileList[0].Name;
        if(Trigger.isbefore && Trigger.isUpdate){            
            if(profileName=='Ops/Quality' || profileName=='Tier 1 TEMP' || profileName=='Tier I CSR CCPA' ||
               profileName=='Tier I CSR PVH' || profileName=='Tier I CSR Wholesale' || profileName=='Tier II CSR' ||
               profileName=='Tier III CSR/Supervisor' ||  profileName=='Tier III CSR/Supervisor'){
                   
                   Set<Id> conId=new Set<Id>();
                   List<Contact> conList=new  List<Contact>();
                   
                   for (Contact con : trigger.new) 
                   {
                       if(Trigger.isUpdate && Trigger.oldMap.get(con.id).HasOptedOutOfEmail != con.HasOptedOutOfEmail){
                           conList.add(con);
                       }
                       
                   }
                   
                   if(conList.size()>0){
                       
                       for(Contact con:conList){
                           if(con.HasOptedOutOfEmail==True && con.EmailOptInStatus__c!='N'){
                               con.EmailOptInStatus__c='N';
                               con.EmailOptOutDate__c=system.now();
                           }
                           else if(con.HasOptedOutOfEmail==False && con.EmailOptInStatus__c!='Y'){
                               con.EmailOptInStatus__c='Y';
                               con.EmailOptInDate__c=system.now();
                           }
                       }
                   }
               }
            //NASSC-3318   
            List<Contact> mcConList=new  List<Contact>();
             List<Contact> keyWordConList=new  List<Contact>();
            if(userName=='MC Integration'){
                for (Contact con : trigger.new) 
                {	
                    if((Trigger.isUpdate && Trigger.oldMap.get(con.id).HasOptedOutOfEmail != con.HasOptedOutOfEmail) &&  con.HasOptedOutOfEmail==True){
                        mcConList.add(con);    
                    }
                   
                }
            }   
            for (Contact con : mcConList){ 
                system.debug('userName***'+userName);
                if(userName=='MC Integration'){
                    if(con.HasOptedOutOfEmail==True && con.EmailOptInStatus__c!='N'){
                        con.EmailOptInStatus__c='N';
                        con.EmailOptOutDate__c=system.now();
                        con.UnsubReason__c='Native Unsubscribe';
                        
                    }
                   
                  
                }
            }
            /**End**/
            //NACDT-5317
            for (Contact con : trigger.new){
                if(String.isNotBlank(con.SMSLocale__c) && con.SMSLocale__c.length() == 5){ 
                    con.CountryOfCapture__c = con.SMSLocale__c.right(2).toUpperCase();
                    
                }
            }
        }
        
        if(Trigger.isBefore){
            if(trigger.new != null){
                for (Contact objCon : trigger.new){
                    if(Trigger.isInsert  ){
                        if(objCon.B2C_Customer_No__c!=null && objCon.Ecomm_Connected__c==false ){
                            objCon.Ecomm_Connected__c=true;
                        }
                        objCon.Zenkraft_Mailing_Street__c= (String.isNotBlank(objCon.mailingstreet) ? objCon.mailingstreet : '')+(String.isNotBlank(objCon.mailingstreet) ? ',' : '')
                            + (String.isNotBlank(objCon.suite__c) ? ' ' + objCon.suite__c : '');
                        if(objCon.LoyaltyFlag__c==true && userName!='MuleSoft APIUser'){//Need to check
                            objcon.Loyalty_Optin_Date__c=System.now();
                        }
                        if(userName!='MuleSoft APIUser'){
                            if(objCon.EmailOptInStatus__c=='Y'){
                                objCon.EmailOptInDate__c=system.now();
                            }else if(objCon.EmailOptInStatus__c=='N'){
                                objCon.EmailOptOutDate__c=system.now();
                                objCon.HasOptedOutOfEmail=true;
                            }
                        }
                        if(mapDataSource.containsKey(objCon.Brand_Id__c+objCon.WelcomeSource__c)){
                            objCon.EmailOrigSource__c=mapDataSource.get(objCon.Brand_Id__c+objCon.WelcomeSource__c).DataSource__c;
                        }
                    }
                    if(Trigger.isUpdate){
                        System.debug('objCon.B2C_Customer_No__c : '+objCon.B2C_Customer_No__c);
                        if(objCon.B2C_Customer_No__c!=null ){
                            System.debug('Entered here');
                            objCon.Ecomm_Connected__c=true;
                            if(userName == 'SFCC Integration User' && objCon.B2C_Is_Enabled__c == false){
                               objCon.B2C_Is_Enabled__c = true; 
                            }
                        }
                        if(objCon.suite__c!=Trigger.oldMap.get(objCon.Id).suite__c ||objCon.mailingstreet!=Trigger.oldMap.get(objCon.Id).mailingstreet){
                            objCon.Zenkraft_Mailing_Street__c= (String.isNotBlank(objCon.mailingstreet) ? objCon.mailingstreet : '')+(String.isNotBlank(objCon.mailingstreet) ? ',' : '')
                                + (String.isNotBlank(objCon.suite__c) ? ' ' + objCon.suite__c : ''); 
                        }
                        if((profileName=='Ops/Quality' || profileName=='Tier 1 TEMP' || profileName=='Tier I CSR CCPA' ||
                            profileName=='Tier I CSR PVH' || profileName=='Tier I CSR Wholesale' || profileName=='Tier II CSR' ||
                            profileName=='Tier III CSR/Supervisor' ||  profileName=='Tier III CSR/Supervisor') && Trigger.oldMap.get(objCon.Id).Bulk_Buyer__c==false  && objCon.Bulk_Buyer__c==true && objCon.LoyaltyFlag__c==false ){
                                objCon.Bulk_Buyer_Update_Reason__c='RC01-CDP Diagnosed Fraud Prevention';
                                objCon.Bulk_Buyer_Update_Date__c=System.now();
                            }
                        if(Trigger.oldMap.get(objCon.Id).LoyaltyFlag__c!=objCon.LoyaltyFlag__c && objCon.LoyaltyFlag__c==true && userName!='MuleSoft APIUser' ){
                            objcon.Loyalty_Optin_Date__c=System.now();
                        }
                        if(userName!='MuleSoft APIUser'){//need to check
                            if((objCon.EmailOptInStatus__c=='Y' && objCon.EmailOptInStatus__c!=Trigger.oldMap.get(objCon.Id).EmailOptInStatus__c ) || (objCon.HasOptedOutOfEmail==false && objCon.HasOptedOutOfEmail!=Trigger.oldMap.get(objCon.Id).HasOptedOutOfEmail)){
                                objCon.EmailOptInDate__c=system.now();
                                objCon.EmailOptInStatus__c='Y';
                                objCon.HasOptedOutOfEmail=false;
                            }else  if((objCon.EmailOptInStatus__c=='N' && objCon.EmailOptInStatus__c!=Trigger.oldMap.get(objCon.Id).EmailOptInStatus__c ) || (objCon.HasOptedOutOfEmail==true && objCon.HasOptedOutOfEmail!=Trigger.oldMap.get(objCon.Id).HasOptedOutOfEmail)){
                                objCon.EmailOptInStatus__c='N';
                                objCon.HasOptedOutOfEmail=true;
                                objCon.EmailOptOutDate__c=system.now();
                            }
                        }
                        if((Trigger.oldMap.get(objCon.Id).Brand_Id__c!=objCon.Brand_Id__c || Trigger.oldMap.get(objCon.Id).WelcomeSource__c!=objCon.WelcomeSource__c) && mapDataSource.containsKey(objCon.Brand_Id__c+objCon.WelcomeSource__c)){
                            objCon.EmailOrigSource__c=mapDataSource.get(objCon.Brand_Id__c+objCon.WelcomeSource__c).DataSource__c;
                        }
                    }
                }
            }
        }        
    }   
    
    if((Trigger.isAfter && Trigger.isUpdate) && LoyaltyIdGeneration.runFlag)
    {
        
        
        Map<Id,Contact> conId=new Map<Id,Contact>();
        set<String> brandSet = new Set<String>();
        String conLoyaltyId;
        String brandCodes= '1,2,4,5,9,81,82,84';
        boolean isLoyaltyBrand=false;
        
        
        
        for (Contact con : trigger.new) 
        {
            if(!Test.isRunningTest()){ 
                conLoyaltyId = String.valueof(con.LoyaltyID__c);
                if(con.Brand_Id__c!=Null && brandCodes.contains(con.Brand_Id__c)!=Null){
                    isLoyaltyBrand=True;
                }
                
                if(UserInfo.getLastName()!='Platform Integration User' 
                   && con.LoyaltyID__c==Null && isLoyaltyBrand==True)
                {
                    
                    conId.put(con.Id,con);
                    brandSet.add(con.Brand_Id__c);
                }           
            }            
        }
        if(conId.size()>0)
        { 
            
            LoyaltyIdGeneration.runFlag=false;
            LoyaltyIdGeneration.loyaltyIdGenHandler(conId,brandSet);
        }         
    }
    
    if (utilityClass.triggerEnabled( 'et4ae5' )) {
        //Note the override of the trigger name for marketing cloud integrations.
        
        If (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            Organization org = [Select isSandbox from Organization LIMIT 1];
            if (!org.IsSandbox) {
                List <LoyaltySettings__mdt> TSEnabledList = new List<LoyaltySettings__mdt>();
                TSEnabledList = [select BrandId__c from LoyaltySettings__mdt where EnableTriggeredSend__c = true];
                Set <String> TSEnabledBrandsSet = new Set<String>();
                if (TSEnabledList.size()>0) {
                    for (LoyaltySettings__mdt LS : TSEnabledList){
                        TSEnabledBrandsSet.add(LS.BrandId__c);
                    }                    
                }              
                
                Boolean callSFMCConnector = false;
                for (Contact c : trigger.new) {
                    if ((c.External_Id__c==null) && (TSEnabledBrandsSet.contains(c.Brand_Id__c)) && (c.Source_System__c == 'WiFi' || c.Source_System__c == 'ChargeItSpot') && (c.EmailOptInStatus__c == 'Y')) {
                        if (!callSFMCConnector) callSFMCConnector = true;
                    }
                }                
                if (callSFMCConnector) et4ae5.triggerUtility.automate('Contact');
            }
        }
    }
    
    TriggerFactory.createAndExecuteHandler(ContactTriggerHandler.class); 
 
}