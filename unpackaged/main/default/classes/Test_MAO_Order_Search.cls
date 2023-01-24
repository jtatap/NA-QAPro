@isTest
public class Test_MAO_Order_Search {

    //@testSetup
    static void createData () {
        Account acc = new Account();
        acc.Name = 'generic Account' + Math.random();
        insert acc;
        
        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact ' + Math.random();
        con.AccountId = acc.id;
        con.Brand_Id__c='1';
        insert con;
        
         Case c = new Case(
                ContactId=con.Id,
                AccountId=acc.Id,
                Origin='Chat',
                Brand__c='2',
                Status='Open',
                RecordTypeId=Constants.supportCaseRecordTypeId
        );
        //insert c;
    }
    
    @isTest(SeeAllData=true)
    static void testCreateTask () {
        Test.startTest();
        List<Case> cases = [SELECT Id, ContactId FROM Case LIMIT 1];
        System.assert(cases.size() > 0, 'Unable to find cases');
        
        Task simpleTask = new Task ();
        simpleTask.Subject = 'URL : - Customer search ';
        simpleTask.Description = 'SOME description';
        simpleTask.Status = 'Closed';
        simpleTask.Priority = 'Normal';
        simpleTask.WhoId = cases[0].ContactId;
        simpleTask.WhatId = cases[0].Id;
        simpleTask.TaskSubtype  = 'Email';
        
        String res = MAO_Order_Search.createTask (JSON.serialize(simpleTask));
        
        Task resultTask = (Task) JSON.deserialize(res, Task.class);
        
        System.assert(resultTask.Id != null, 'Failed to create task');
        Test.stopTest();
    }
}