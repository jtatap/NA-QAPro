/**
 * Created by bryananderson on 10/7/19.
 */

global class DeleteContentDocumentBatch implements
                Database.Batchable<sObject>, Database.Stateful {

    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT pcify__RecordId__c FROM pcify__Log__c WHERE (pcify__CreditCardDetected__c = TRUE OR pcify__Category__c = \'Record Deleted\') AND pcify__Object__c = \'ContentVersion\' ORDER BY CreatedDate DESC');
    }

    global void execute(Database.BatchableContext bc, List<pcify__Log__c> scope) {
        Set<Id> contentVersionIds = new Set<Id>();

        for (pcify__Log__c log : scope) {
            contentVersionIds.add(log.pcify__RecordId__c);
        }

        system.debug(contentVersionIds);

        Set<ContentVersion> cvSet = new Set<ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]);

        system.debug('cvSet=== ' + cvSet);

        Set<Id> cdSet = new Set<Id>();

        for (ContentVersion cv: cvSet) {
            cdSet.add(cv.ContentDocumentId);
        }

        List<ContentDocument> cdList = Database.Query('SELECT Id FROM ContentDocument WHERE Id IN :cdSet AND IsDeleted = false');

        system.debug('cdList=== ' + cdList);

        for (ContentDocument cd : cdList) {
            recordsProcessed = recordsProcessed + 1;
        }
        delete cdList;
    }
    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed.');

        System.scheduleBatch(new DeleteContentDocumentBatch(), 'Delete ContentDocument containing Credit Card ' + DateTime.now() + ' - ' + Math.random(), 5);
    }
}