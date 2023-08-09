@isTest
private class NF_AgentWorkTriggerHelperTest {

    @isTest
    static void testRollupActiveTime() {
        Account genAcc = new Account();
        genAcc.Name = 'generic Account' + Math.random();
        insert genAcc;

        Contact genCon = new Contact();
        genCon.email = 'foo@example.com';
        genCon.lastName = 'generic contact ' + Math.random();
        genCon.AccountId = genAcc.id;
        genCon.Brand_Id__c = '1';
        insert genCon;

        GenericRecords__c genRec = new GenericRecords__c(Name = Constants.privacyContactGenericRecordSettingName, recordId__c = genCon.Id);
        insert genRec;

        GenericRecords__c genRecAcct = new GenericRecords__c(Name = Constants.AccountGenericRecordSettingName, recordId__c = genAcc.Id);
        insert genRecAcct;

        // create test cases
        Case testCase1 = new Case(Subject='Test Case 1');
        insert testCase1;
        Case testCase2 = new Case(Subject='Test Case 2');
        insert testCase2;

        // create test agent works
        AgentWork testWork1 = new AgentWork(WorkItemId = testCase1.Id, ServiceChannelId =null);

        NF_AgentWorkTriggerHandler.disableTrigger = true;
        Try{
            insert testWork1;

        }catch(Exception e){

        }

        NF_AgentWorkTriggerHandler.disableTrigger = false;

        List<AgentWork> testWorks = new List<AgentWork> {testWork1};

        // test the rollupActiveTime method
        try{
            Boolean result = NF_AgentWorkTriggerHelper.rollupActiveTime(testWorks);

        }
        catch(Exception e){

        }
    }


    static testMethod void testHandleAfterUpdate() {
            Account genAcc = new Account();
            genAcc.Name = 'generic Account' + Math.random();
            insert genAcc;

            Contact genCon = new Contact();
            genCon.email = 'foo@example.com';
            genCon.lastName = 'generic contact ' + Math.random();
            genCon.AccountId = genAcc.id;
            genCon.Brand_Id__c = '1';
            insert genCon;

            GenericRecords__c genRec = new GenericRecords__c(Name = Constants.privacyContactGenericRecordSettingName, recordId__c = genCon.Id);
            insert genRec;

            GenericRecords__c genRecAcct = new GenericRecords__c(Name = Constants.AccountGenericRecordSettingName, recordId__c = genAcc.Id);
            insert genRecAcct;

            // Create test data
            // create test cases
            Case testCase = new Case(Subject='Test Case 1');
            insert testCase;
    		
            
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;

            List<LiveChatTranscript> testChats = new List<LiveChatTranscript>{
                    new LiveChatTranscript(LiveChatVisitoriD = visitor.iD)
            };

            // Insert test data
            insert testChats;
       		
        	ServiceChannel sc = [Select Id from ServiceChannel where DeveloperName = 'Case' Limit 1];
			// create test agent works
            AgentWork testWork = new AgentWork( WorkItemId = testCase.Id,UserId= userInfo.getUserId(), ServiceChannelId = sc.Id);
			NF_AgentWorkTriggerHandler.disableTrigger = true;
        	insert testWork;
            NF_AgentWorkTriggerHandler.disableTrigger = false;
        	AgentWork wrk = [Select Id,PendingServiceRoutingId from AgentWork  where Id =: testWork.Id];

            // Create a map of old AgentWork records
        	Map<Id,AgentWork> oldMap = new Map<Id,AgentWork>{testWork.Id => testWork};
                Map<Id,AgentWork> newMap = new Map<Id,AgentWork>{testWork.Id => new AgentWork(Id= testWork.Id, WorkItemId = testCase.Id,UserId= userInfo.getUserId(), ServiceChannelId = sc.Id)};
                
			Boolean originalQueue = false;
            Test.startTest();
            // Call the method under test
            
            try{
                
                NF_AgentWorkTriggerHelper.handleAfterUpdate(newMap, oldMap);
				originalQueue = NF_AgentWorkTriggerHelper.updateOriginalQueue(newMap.Values());
                NF_AgentWorkTriggerHelper.rollupActiveTime(newMap.Values());
            }
            catch(Exception e){
					system.debug('%$%$'+e.getStackTraceString());
            }
        	Test.StopTest();
        	system.assertEquals(true, originalQueue);
    }

    @isTest
    private static void testUpdateOriginalQueue() {
        // Create test data
        List<AgentWork> newWorks = new List<AgentWork>();
        for (Integer i = 0; i < 5; i++) {
            AgentWork aw = new AgentWork();
            newWorks.add(aw);
        }

        // Test updateOriginalQueue method 
        Test.startTest();
        Boolean result = NF_AgentWorkTriggerHelper.updateOriginalQueue(newWorks);
        Test.stopTest();
    }
    
    
   
  /*  @isTest
    static void TestAbc(){
        NF_AgentWorkTriggerHelper nf = new NF_AgentWorkTriggerHelper();
        nf.abcMethod();
        
    } */
}