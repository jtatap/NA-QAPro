/**
* @author         Hemadri Ravilla   <hemadri@stabilistech.com>
* @modifiedBy     Hemadri Ravilla   <hemadri@stabilistech.com>
* @version        1.0
* @created        2021-10-25
* @modified       2021-10-25
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Description     SFCCRewardUpdate will update the status in SFSC based the Operation Type recieved from SFCC
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/SFCCRewards/Update')
global class SFCCRewardUpdate {
    global class SubRequest {
        public String BrandId;
        public string LoyaltyId ;
        public String Status;
        public List<string> RewardId;
        public String OperationType;
        public String OrderId;
    }  
    global class RewardId {
        public String RewardId;
    }
    global class RewardIds {
        public String LoyaltyId;
        public String Message;
        public String RewardId;
    }
    global class SubResponse{
        public String Code;
        public List<RewardIds> RewardIds;
    }
    @httpPost
    global static void doUpdate(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String requestData = req.requestBody.toString();
        system.debug('requestData>>>'+requestData);
        SubRequest subReqReceived = (SubRequest)JSON.deserialize(requestData,SubRequest.class);
        system.debug('subReqReceived>>>'+subReqReceived);
        SubResponse objres1=new SubResponse();
        List<RewardIds> lstRewd=new List<RewardIds>();
        RewardIds objRew;
        if (String.IsBlank(subReqReceived.LoyaltyId) || string.IsBlank(subReqReceived.BrandId) || subReqReceived.RewardId.size()<1) {
            objRew=new RewardIds();
            res.statusCode = 400;            
            objres1.code='INVALID_QUERY'; 
            objRew.message='Missing required parameters BrandId Or LoyaltyId Or RewardId';
            lstRewd.add(objRew);
            objres1.RewardIds=lstRewd;
            res.responseBody = Blob.valueOf(JSON.serialize(objres1));
            //system.debug('test>>>,,'+BrandId);
            return;
        }else if(subReqReceived.BrandId=='2'){
            Map<Id,Reward__c> getMapOfRewards=rewardsUpdate(subReqReceived);
            if(getMapOfRewards.size()>0){
                system.debug('helper method size>>'+getMapOfRewards.size());
                Database.SaveResult[] srList = Database.update(getMapOfRewards.values(), false);
                set<id> setSuccId=new set<id>();
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        setSuccId.add(sr.getId());
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }                    
                }
                res.statusCode = 200;            
                objres1.code='200';
                for(Reward__c objRewd:getMapOfRewards.values()){
                    objRew=new RewardIds();
                    objRew.RewardId=objRewd.RewardId__c;
                    objRew.LoyaltyId=objRewd.LoyaltyId__c;
                    if(setSuccId.contains(objRewd.id)){
                        objRew.Message='Success';                        
                    }else{                        
                        objRew.Message='Failure';                        
                    }
                    lstRewd.add(objRew);
                }
                objres1.RewardIds=lstRewd;
                system.debug('test>>>>>'+objres1);
                res.responseBody = Blob.valueOf(JSON.serialize(objres1));
            }
        }else{
            objRew=new RewardIds();
            res.statusCode = 400;            
            objres1.code='INVALID_BRAND'; 
            objRew.message='Invalid BrandId';
            lstRewd.add(objRew);
            objres1.RewardIds=lstRewd;
            res.responseBody = Blob.valueOf(JSON.serialize(objres1));
            //system.debug('test>>>,,'+BrandId);
            return;
        }
    }
    public static Map<Id,Reward__c> rewardsUpdate(SubRequest inputRequest){
        map<id,Reward__c> mapofRewards=new map<id,Reward__c>();
        List<Reward__c> lstrewards=new List<Reward__c>();
        for(Reward__c objrewards:[Select Id,LoyaltyId__c, Reward_Number__c,Web_Order_Id__c, RewardId__c, RewardType__c, Status__c,Web_Operation_Type__c,ExpireDate__c From Reward__c  Where LoyaltyId__c=:inputRequest.LoyaltyId AND RewardId__c IN :inputRequest.RewardId] ){
            objrewards.Web_Operation_Type__c=inputRequest.OperationType;
            if(inputRequest.OperationType=='PendingRedeemed'){
                objrewards.Status__c='Pending Redeemed' ;
            }else{
                objrewards.Status__c='Active' ;
            }
            objrewards.Web_Order_Id__c=inputRequest.OrderId;
            mapofRewards.put(objrewards.id,objrewards);
        }       
        system.debug('helper method>>'+mapofRewards);
        return mapofRewards;
    }
    
}