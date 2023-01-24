/**
 * Created by bryananderson on 10/11/19.
 */

global class DeleteOrphanedFilesBatch implements
                Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM User WHERE UserType = \'Guest\'');
    }

    global void execute(Database.BatchableContext bc, List<User> scope) {
        set<id> gIds = new set<id>();

        for (User u : scope) {
            gIds.add(u.Id);
        }

        system.debug('guest user IDs: ' + gIds);

        list<ContentDocumentLink> orphanedFilesGuest = new list<contentdocumentlink>([SELECT ContentDocumentId,Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :gIds]);

        system.debug('guest user files: ' + orphanedFilesGuest.size());

        if (orphanedFilesGuest.size() > 0) {
            set<id> filesGuest = new set<id>();

            for (ContentDocumentLink cdl : orphanedFilesGuest) {
                filesGuest.add(cdl.ContentDocumentId);
            }

            list<ContentDocumentLink> guestFilesTotal = new list<contentdocumentlink>([SELECT ContentDocumentId,Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :filesGuest]);

            system.debug('total files: ' + guestFilesTotal.size());

            String caseObjKeyPrefix = Case.sObjectType.getDescribe().getKeyPrefix();

            system.debug('caseObjKeyPrefix: ' + caseObjKeyPrefix);

            set<ID> caseEntity = new set<Id>();
            set<ID> userGuestEntity = new set<Id>();

            for (contentdocumentlink cdl : guestFilesTotal) {
                if (String.valueOf(cdl.LinkedEntityId).substring(0, 3) != caseObjKeyPrefix) {
                    userGuestEntity.add(cdl.ContentDocumentId);
                } else {
                    caseEntity.add(cdl.ContentDocumentId);
                }
            }

            for(Id objId: caseEntity){
                if(userGuestEntity.contains(objId))
                    userGuestEntity.remove(objId);
            }

            system.debug('userGuestEntity: ' + userGuestEntity.size());

            system.debug('caseEntity: ' + caseEntity.size());

            DateTime nowDT =  DateTime.now();
            DateTime d24hAgo = nowDT.addHours(-24);


            list<ContentDocument> orphanedFilesFinal = new list<ContentDocument>([select id, createddate from contentDocument where id IN :userGuestEntity AND CreatedDate <= :d24hAgo]);

            system.debug('orphaned files to be deleted, created 24 hours ago or earlier: ' + orphanedFilesFinal.size());
            system.debug(orphanedFilesFinal);
            if (orphanedFilesFinal.size() > 0) {
                delete orphanedFilesFinal;
            }
        }
    }
    global void finish(Database.BatchableContext bc) {

    }
}