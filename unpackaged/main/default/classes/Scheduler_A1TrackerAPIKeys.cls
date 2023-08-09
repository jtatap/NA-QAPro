/******************************************************************************
 * @Description: Scheduler to call an external API to get access keys.
 * @Author     : Trupti Bhirud
 * @Date       : 27:01.2020
 * @JIRA       : NASSC-1346
 *
 ******************************************************************************/
global class Scheduler_A1TrackerAPIKeys implements Schedulable{
  global void execute(SchedulableContext sc){
    setTrackerAPIKeys();
  }

  @future(callout = true)
  public static void setTrackerAPIKeys(){
    Date todayDate = System.today();
    String month = String.valueOf(todayDate.month());
    String day = String.valueOf(todayDate.day());
    if (month.length() == 1)
      month = month.leftPad(2, '0');
    // sets month in MM format if it's single digit
    if (day.length() == 1)
      day = day.leftPad(2, '0');
    // sets day in DD format if it's single digit
    DateTime currentTime = System.now();
    List<A1_TrackerAPI_tokens__mdt> accesstokenRecord = [SELECT MasterLabel, BrandId__c, access_token__c, Label, DeveloperName
                                                     FROM A1_TrackerAPI_tokens__mdt
                                                     WHERE token_expires_at__c > :currentTime AND key_expires_at__c < :currentTime
                                                     limit 1];
    String BCryptAPIKey = [SELECT Secret__c
                       FROM SharedSecret__mdt
                       WHERE DeveloperName = :SYSTEM.LABEL.BCryptService
                       LIMIT 1].Secret__c;
    Log.push('bcrypti ' + BCryptAPIKey);
    if (!accesstokenRecord.isEmpty()){
      //append today's date to access token
      String token = accesstokenRecord[0].access_token__c;
      token = token + todayDate.year() + '-' + month + '-' + day;
      Log.push(token);
      //create json body
      String jsonBody = '{"token" : "' + token + '"}';
      String reqEndPoint = SYSTEM.LABEL.callout_A1_AccesskeyBcryptService;
      //makes API callout
      Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'application/json');  
        req.setHeader('x-api-key', BCryptAPIKey);           
        req.setEndpoint(reqEndPoint);       
        req.setMethod('POST');
        req.setBody(jsonBody);
        res = http.send(req);
      Log.push('body ' + res.getBody());
      if (res.getBody() != null){
        if (res.getStatusCode() == 200){
          TrackerAccessKeyResponse resVal = (TrackerAccessKeyResponse)JSON.deserialize(res.getBody(), TrackerAccessKeyResponse.class);
          accesstokenRecord[0].access_key__c = resVal.key;
          CustomMetadataCallback.updateTrackerAccessKey(accesstokenRecord[0]);
        }
      }
    }
    Logger.logDebug();
  }

  //Wrapper class to collect Access Key response
  public class TrackerAccessKeyResponse{
    public String token;
    public String key;

  }

}