@isTest
public class LogEventTriggerHandlerTest {
@isTest
    static void testcreateLogs(){
        Test.startTest();
        LogEventTriggerHandler leh = new LogEventTriggerHandler();
		Log_Event__e logEvent = new Log_Event__e();
        logEvent.Message__c = 'errorMessage';
        leh.createLogs(new List<Log_Event__e>{logEvent});
        Test.stopTest();
    }
}