public class MAO_Order_Search {
	@AuraEnabled
    public static String createTask (String taskRecordStr) {
		Task simpleTask = (Task) JSON.deserialize(taskRecordStr, Task.class);
        insert simpleTask;
        
        insert new FeedItem(
            ParentId = simpleTask.WhatId, 
            body = simpleTask.Subject + '\n' + simpleTask.Description,
            LinkUrl = URL.getOrgDomainUrl().toExternalForm() + '/'+simpleTask.Id
        );
        //URL.getSalesforceBaseUrl().toExternalForm()+
        return JSON.serialize(simpleTask);
    }
}