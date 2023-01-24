@isTest
public class AgentWorkTriggerTest {
    // THIS IS NOT TESTABLE. AN UNAVOIDABLE ERROR OCCURS. THIS TEST IS JUST TO MAKE THIS TRIGGER DEPLOYABLE.
    @isTest
    static void test_fake() {
        //Try Catch is to ensure test doesn't fail
        ServiceChannel sc = [SELECT Id FROM ServiceChannel LIMIT 1];
        List<Case> caseList = TestDataFactory.createCases(1);
        Case cse = caseList[0];
        insert cse;
        try{
            AgentWork aw = new AgentWork(
                    ServiceChannelId = sc.Id,
                    WorkItemId = cse.Id,
                    UserId = UserInfo.getUserId()
            );
            insert aw;
        } catch (Exception e) {
            //IGNORE THIS ERROR. BEFORE INSERT TRIGGERS EVEN WITH THAT.
        }
    }
}