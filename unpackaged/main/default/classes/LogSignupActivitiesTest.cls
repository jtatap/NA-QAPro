/******************************************************************************
* @Description: Test Class for LogSignupActivities
* @Date		  : April 16, 2020
* @JIRA		  : NASSC-1665
*
******************************************************************************/
@isTest(isParallel=false)
public class LogSignupActivitiesTest {
    
    @isTest
    public static void LogSignUpActivityTest(){
        Contact con = new Contact(Lastname='test', Brand_Id__c='1', Source__c='WE_FOOTER',EventDate__c=System.now(), LoyaltyID__c='TH40000233', StoreOfCapture__c='testcode');
        insert con;
        
        List<LogSignupActivities.SignUpActivityData> ListData = new List<LogSignupActivities.SignUpActivityData>();
        LogSignupActivities.SignUpActivityData objSignUp = new LogSignupActivities.SignUpActivityData();
        objSignUp.ContactId = con.Id;
        objSignUp.eventDate = con.EventDate__c;
        objSignUp.dataSource = con.Source__c;
        objSignUp.BrandId = con.Brand_Id__c;
        objSignUp.loyaltyId = con.LoyaltyID__c;
        objSignUp.StoreCode = con.StoreOfCapture__c;
        ListData.add(objSignUp);
        LogSignupActivities.LogSignUpActivity(ListData);  
    }
}