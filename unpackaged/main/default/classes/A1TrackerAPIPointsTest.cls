@isTest
public class A1TrackerAPIPointsTest {
    static Map<String, String> responseHeaders = new Map<String, String>();
    static void testDatasetup(){
                Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;
        
        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c='9';
        insert genCon;
		
        GenericRecords__c genRec = new GenericRecords__c(
                Name = Constants.privacyContactGenericRecordSettingName,
                recordId__c = genCon.Id
        );
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(
                Name = Constants.AccountGenericRecordSettingName,
                recordId__c = genAcc.Id
        );
        insert genRecAcct;
        Contact con = new Contact(FirstName='Test',LastName='User',Brand_Id__c='2', LoyaltyID__c='123456789',Email='testUser@nomail.com');
        insert con;
        System.debug(con.Id);
        Case cas = new Case(Origin='Email',Status='New',Brand__c='2',Subject='Test Case',ContactId=con.Id);
        insert cas;
        System.debug('Case contact '+cas.ContactId+'--'+cas.Contact.Brand_Id__c);
        
    }

    @isTest
    static void futurePostTrackerAPIEventstest(){
        DateTime myDateTime = datetime.newInstance(2019, 9, 15, 12, 30, 0);
        Test.startTest();
        testDatasetup();
        List<Case> caseList = new List<Case>();
        Contact con = new Contact(FirstName='Test',LastName='User',Brand_Id__c='2', LoyaltyID__c='123456789',Email='testUser@nomail.com');
        insert con;
        //Case cas = new Case(Origin='Email',Status='New',Brand__c='2',Subject='Test Case',ContactId=con.Id);
        Case cas = new Case(Origin='Email',Status='New',Brand__c='2',Subject='Test Case',ContactId=con.Id,PointsAdjustmentTimeStamp__c=myDateTime,PointsGranted__c=100,LoyaltyComments__c='Testing');
        caseList.add(cas);
        /*
        Case cas1 = new Case(Origin='Email',Status='New',Brand__c='2',Subject='Test Case',ContactId=con.Id);
        caseList.add(cas1);
        Case cas2 = new Case(Origin='Email',Status='New',Brand__c='2',Subject='Test Case',ContactId=con.Id);
        caseList.add(cas2);
        Case cas3 = new Case(Origin='Email',Status='New',Brand__c='2',Subject='Test Case',ContactId=con.Id);
        caseList.add(cas3);
		*/
        insert caseList;
        System.debug('***inserted case='+caseList[0]);
        responseHeaders.put('Content-Type', 'application/json');
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'OK',
                '{"access_token":"ecdc4492-8a1c-4f03-b9ad-6b9db87f61a1","token_type":"bearer","expires_in":15445210}',
                responseHeaders);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Map<Id,Case> cases = new Map<Id,Case>([SELECT Id FROM Case limit 100]);
        List<Id> caseId = new List<Id>(cases.keySet());
        List<Id> listCasesIds = new List<Id>();
        listCasesIds.add(caseList[0].Id);
        A1TrackerAPIPoints.invokePostTrackerAPIPoints(listCasesIds);
        Test.stopTest();
    }

}