/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'29, 2020
* @TestClass: LoggerTest
*/
@isTest
private class LoggerTest {
    
    private enum LogLevel {FATAL, ERROR, INFO, DEBUG}

    @IsTest
    static void testLogAPIInfo(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
        request.setMethod('GET');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animals":["majestic badger","fluffy bunny","scary bear","chicken"]}');
        response.setStatusCode(200);

        Test.startTest();
            Logger.logAPIInfo(request, response);
        Test.stopTest();

        System.assertEquals(true, [SELECT Id FROM Log__c WHERE Level__c =: String.valueOf(LogLevel.INFO)].size()>0, 'FATAL');
    }

    @IsTest
    static void testLogException(){
        Lead newLead = new Lead();
        newLead.Company = 'NF';

        Test.startTest();
            try{
                insert newLead;
            } catch(Exception ex){
                Logger.logException(ex);
            }
        Test.stopTest();

        System.assertEquals(true, [SELECT Id FROM Log__c WHERE Level__c =: String.valueOf(LogLevel.FATAL)].size()>0, 'FATAL');
    }

    @IsTest
    static void testLogError(){

        Test.startTest();
           Logger.logError('Something went wrong.');
        Test.stopTest();

        System.assertEquals(true, [SELECT Id FROM Log__c WHERE Level__c =: String.valueOf(LogLevel.ERROR)].size()>0, 'FATAL');
    }

    @IsTest
    static void testLogDatabaseError(){
        List<Lead> leadList = new List<Lead>();
        Boolean isArchived;
            
        for(Integer i=0; i<10; i++){
            Lead newLead = new Lead();
            if(Math.mod(i, 2) == 0){
                newLead.LastName = 'Test Lead '+i;
            }
            newLead.Company = 'NF';
            leadList.add(newLead);
        }
        List<Database.SaveResult> srList = Database.insert(leadList, false);

        Test.startTest();
            Logger.logDatabaseError(srList);   
            isArchived = new LogArchivalBatch().isArchivalSuccessful(srList);
        Test.stopTest();

        System.assertEquals(true, [SELECT Id FROM Log__c WHERE Level__c =: String.valueOf(LogLevel.ERROR)].size()>0, 'FATAL');
        System.assertEquals(false, isArchived, 'FATAL');
    }

    @IsTest
    static void testLogDebug(){
        Test.startTest();
            Log.push('LoggerTest > testLogDebug > ENTRY');
            Log.push('Push message');
            Log.pop();
            Logger.logDebug();
        Test.stopTest();

        System.assertEquals(true, [SELECT Id FROM Log__c WHERE Level__c =: String.valueOf(LogLevel.DEBUG)].size()>0, 'FATAL');
    }
}