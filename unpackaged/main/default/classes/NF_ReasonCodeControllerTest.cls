@isTest(isParallel=false)
public with sharing class NF_ReasonCodeControllerTest {
    @isTest static void NF_ReasonCodeControllerTest() {
        Test.startTest();
        User tuser = NF_Util.getPlatformIntegrationUser();
        Case c = new Case();
        System.runAs(tuser) {
            c.Status = 'Open';
            c.OwnerId =tuser.Id;
            insert c;
        }
        Case aCase = NF_ReasonCodeController.getCase( (String) c.Id);
        System.assert(aCase != null);
        Test.stopTest();
   }
}