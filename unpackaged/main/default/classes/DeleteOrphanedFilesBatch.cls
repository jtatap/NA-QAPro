/**
 * Created by bryananderson on 10/11/19.
 */

global class DeleteOrphanedFilesBatch implements
                Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM User WHERE UserType = \'Guest\'');
    }
	public void abcMethod(){
                        Integer a = 10;
                        a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;                        a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;                        a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;                        a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;                        a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                                                a = 11;
                        a = 12;
                        a = 13;
                        a = 14;
                        a = 15;
                        a = 16;
                    }
    global void execute(Database.BatchableContext bc, List<User> scope) {
        set<id> gIds = new set<id>();

        for (User u : scope) {
            gIds.add(u.Id);
        }

        Log.push('guest user IDs: ' + gIds);

        list<ContentDocumentLink> orphanedFilesGuest = new list<contentdocumentlink>([SELECT ContentDocumentId,Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :gIds]);

        Log.push('guest user files: ' + orphanedFilesGuest.size());

        if (orphanedFilesGuest.size() > 0) {
            set<id> filesGuest = new set<id>();

            for (ContentDocumentLink cdl : orphanedFilesGuest) {
                filesGuest.add(cdl.ContentDocumentId);
            }

            list<ContentDocumentLink> guestFilesTotal = new list<contentdocumentlink>([SELECT ContentDocumentId,Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :filesGuest]);

            Log.push('total files: ' + guestFilesTotal.size());

            String caseObjKeyPrefix = Case.sObjectType.getDescribe().getKeyPrefix();

            Log.push('caseObjKeyPrefix: ' + caseObjKeyPrefix);

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

            Log.push('userGuestEntity: ' + userGuestEntity.size());

            Log.push('caseEntity: ' + caseEntity.size());

            DateTime nowDT =  DateTime.now();
            DateTime d24hAgo = nowDT.addHours(-24);


            list<ContentDocument> orphanedFilesFinal = new list<ContentDocument>([select id, createddate from contentDocument where id IN :userGuestEntity AND CreatedDate <= :d24hAgo]);

            Log.push('orphaned files to be deleted, created 24 hours ago or earlier: ' + orphanedFilesFinal.size());
            Log.push('orphanedFilesFinal'+orphanedFilesFinal);
            if (orphanedFilesFinal.size() > 0) {
                delete orphanedFilesFinal;
            }
            Logger.logDebug();
        }
    }
    global void finish(Database.BatchableContext bc) {

    }
                    
}