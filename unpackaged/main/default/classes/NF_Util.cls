/**
 * Created by apoorvrajput on 9/10/20.
 */

public with sharing class NF_Util {

    public static final String ORIGIN = SYSTEM.LABEL.Chat;
    public static String TOMMY = SYSTEM.LABEL.Tommy_Hilfiger;
    public static String CALVIN = SYSTEM.LABEL.Calvin_Klein;
    public static String IZOD = SYSTEM.LABEL.IZOD;
    public static String VAN = SYSTEM.LABEL.Van_Heusen;
    public static final String RECORD_TYPE = SYSTEM.LABEL.Chat_Case;

    public static String getLastBusinessIntent(String chatKey){
        String lastBusinessIntent = '';
        try {
            ebotdata__Bot_Session__c botSession = NF_Util.getBotSession(chatKey);
            Log.push('>>NF_Util.getFirstUserInput botSession=' + botSession);

            if (botSession != null) {
                for (ebotdata__Bot_Chat_Log__c chatLog : [
                        SELECT Id, ebotdata__Intent_Name__c
                        FROM ebotdata__Bot_Chat_Log__c
                        WHERE ebotdata__Bot_Session__c = :botSession.Id
                        ORDER BY Name ASC
                        LIMIT 10
                ]) {

                    Log.push('>>NF_Util.getLastBusinessIntent: ebotdata__Intent_Name__c=' + chatLog.ebotdata__Intent_Name__c);
                    if (String.isNotEmpty(chatLog.ebotdata__Intent_Name__c) && chatLog.ebotdata__Intent_Name__c.substring(0, 3) == 'bus') {
                        lastBusinessIntent = chatLog.ebotdata__Intent_Name__c;
                        break;
                    }
                }
            }
        }catch(Exception e){
            Logger.logException(e);
        }
        Logger.logDebug();
        return lastBusinessIntent;
    }

    public static RecordType getRecordType(){
        RecordType[] recordTypes = [
                SELECT Id
                FROM RecordType
                WHERE Name = :RECORD_TYPE
                LIMIT 1
        ];

        return recordTypes.size() > 0 ? recordTypes[0] : null;
    }

    public static Map<String, String> channelMapping = new Map<String, String>{
            TOMMY => SYSTEM.LABEL.Online_Tommy_com,
            CALVIN => SYSTEM.LABEL.Online_CalvinKlein_com,
            IZOD => SYSTEM.LABEL.Online_Izod_com,
            VAN => SYSTEM.LABEL.Online_vanheusen_com
    };

    public static Map<String, String> buttonMapping = new Map<String, String>{
            TOMMY => SYSTEM.LABEL.Tommy_Prioritized_Chat,
            CALVIN => SYSTEM.LABEL.Calvin_Klein_Prioritized_Chat,
            IZOD => SYSTEM.LABEL.Partner_Brands_Prioritized_Chat,
            VAN => SYSTEM.LABEL.Partner_Brands_Prioritized_Chat
    };

    public static Map<String, String> deploymentMapping = new Map<String, String> {
            TOMMY => SYSTEM.LABEL.Tommy_Prioritized_Chat,
            CALVIN => SYSTEM.LABEL.Calvin_Klein_Prioritized_Chat,
            IZOD => SYSTEM.LABEL.Partner_Brands_Prioritized_Chat,
            VAN => SYSTEM.LABEL.Partner_Brands_Prioritized_Chat
    };

    public static Map<String, String> queueMapping = new Map<String, String> {
            TOMMY => SYSTEM.LABEL.Tommy_Chat_Priority,
            CALVIN => SYSTEM.LABEL.Calvin_Klein_Chat_Priority,
            IZOD => SYSTEM.LABEL.Partner_Brands_Chat_Priority,
            VAN => SYSTEM.LABEL.Partner_Brands_Chat_Priority
    };

    public static Brand_Setting__mdt getBrandName(String URL){
        Log.push(URL);
        String brandName = '';
        String backup = URL.toUpperCase();
        URL = URL.toUpperCase();
        URL = URL.remove('HTTPS');
        URL = URL.remove('HTTP');
        URL = URL.remove('//');
        URL = URL.substringBefore('/');
        Log.push(URL +', ' +backup);
        // this is a test domain.
        if(URL.contains(SYSTEM.LABEL.NEURAFLASH) || URL.contains(SYSTEM.LABEL.PVHSERVICECLOUD)) {
            URL = backup;
            Log.push('USING backup'+ URL +', ' +URL.contains('CALVIN'));

        }
        if(URL.contains(SYSTEM.LABEL.TH) || URL.contains(SYSTEM.LABEL.TOMMY) || URL.contains(SYSTEM.LABEL.HILFIGER))
            brandName = SYSTEM.LABEL.Tommy_Hilfiger1;
        else if(URL.contains(SYSTEM.LABEL.CK) || URL.contains(SYSTEM.LABEL.CALVIN) || URL.contains(SYSTEM.LABEL.KLEIN))
            brandName = SYSTEM.LABEL.Calvin_Klein1;
        else if(URL.contains(SYSTEM.LABEL.IZOD) || URL.contains(SYSTEM.LABEL.IZOD) || URL.contains(SYSTEM.LABEL.IZ))
            brandName = SYSTEM.LABEL.IZOD;
        else if(URL.contains(SYSTEM.LABEL.VH) || URL.contains(SYSTEM.LABEL.HEUSEN) || URL.contains(SYSTEM.LABEL.VAN))
            brandName = SYSTEM.LABEL.Van_Heusen1;

        List<Brand_Setting__mdt> configs = new List<Brand_Setting__mdt>();
        try{
            configs = [SELECT Id, Community_Name__c, Brand_Id__c, Label, Brand_Email__c, Brand_Phone__c, Shipping_Questions_URL__c, Covid_URL__c, Return_Questions_URL__c, Return_URL__c, Product_Questions_URL__c, Promotions_URL__c, Order_Status_URL__c
            FROM Brand_Setting__mdt
            WHERE DeveloperName = :brandName];
        }
        catch(Exception e) {
            Logger.logException(e);
        }
        Logger.logDebug();
        return configs.size() > 0 ? configs[0] : null;
    }

    public static void insertSession(String chatKey, String payload, String brand){
        Log.push('bot session creation started.');
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.CarouselContent__c = payload;
        session.ebotdata__Live_Agent_Session_Id__c = chatKey;
        //session.ebotdata__Live_Chat_Transcript__c = chatKey;
        session.Brand__c = brand;
        insert session;
        Log.push('bot session created');
        Logger.logDebug();
    }

    public static User getPlatformIntegrationUser(){
        User[] users = [SELECT Id, Name FROM User WHERE Name =: SYSTEM.LABEL.Automated_Process LIMIT 1];
        return users.size() > 0 ? users[0] : null;
    }

    public static String getDomainName(String url) {
        try {

            Url uri = new Url(url);
            String domain = uri.getHost();
            Log.push('Host is: '+ domain);
            Logger.logDebug();
            return domain.startsWith('www.') ? domain.substring(4) : domain;
        }
        catch (Exception e) {
            Logger.logException(e);
        }
        return '';
    }

    public static List<String> splitFullNameIntoFirstAndLast(String fullName){
        //grab the first name and parse it
        String firstName;
        String lastName;
        List<String> resultList = new List<String>();
        if (!String.isEmpty(fullName)) {
            //tokenize the full name
            List<String> names = fullName.split(' ');
            if (!names.isEmpty()) {
                //set the first name, and a default last name
                firstName = names.remove(0);
                lastName = SYSTEM.LABEL.NA;

                if (!names.isEmpty()) {
                    lastName = names[0];
                    names.remove(0);
                    while (!names.isEmpty()) {
                        lastName += ' ' + names[0];
                        names.remove(0);
                    }
                }
            }
        }
        resultList.add(firstName);
        resultList.add(lastName);
        return resultList;
    }

    public static Account getContact(String email) {
        List<Account> contactList = new List<Account>();
        try{
            if(String.isNotBlank(email)) {
                contactList =   [SELECT Id,FirstName__c, LastName__c
                FROM Account
                WHERE AccountEmail__c = :email];
            }
        }
        catch(Exception e) {
            Logger.logException(e);
        }
        return contactList.size() > 0 ? contactList[0] : null;
    }

    public static Contact getContact(String email, String accountId, String brand) {
        List<Contact> contactList = new List<Contact>();
        List<Brand_Setting__mdt> configs = new List<Brand_Setting__mdt>();
        Log.push('brand is:'+brand  + 'email is: '+email);

        if(!String.isBlank(brand))
            try{
                configs = [SELECT Brand_Id__c
                FROM Brand_Setting__mdt
                WHERE Label = :brand];
            }catch(Exception e) {
                Logger.logException(e);
            }

        try{
            if(String.isNotBlank(email) && configs.size() > 0) {
                contactList =   [SELECT Id,FirstName, LastName
                FROM Contact
                // account creation removal.
                //WHERE Email = :email and AccountId = :accountId and Brand_Id__c = :configs[0].Brand_Id__c];
                WHERE Email = :email and Brand_Id__c = :configs[0].Brand_Id__c];
            }
            else if(String.isNotBlank(email) && configs.size() == 0) {
                contactList =   [SELECT Id, FirstName, LastName
                FROM Contact
                // account creation removal.
                //WHERE Email = :email and AccountId = :accountId];
                WHERE Email = :email ];
            }
            Log.push('Returning contact list: '+contactList);
        }
        catch(Exception e) {
            Logger.logException(e);
        }
        Logger.logDebug();
        return contactList.size() > 0 ? contactList[0] : null;

    }

    public static Case getCaseRelatedToContact(String contactId) {
        List<Case> caseList = new List<Case>();
        try {
            DateTime compareDate = System.now().addHours(-72);
            if (String.isNotBlank(contactId)) {
                caseList = [
                        SELECT ID, CaseNumber, ContactId, CreatedDate, LastModifiedDate
                        FROM Case
                        WHERE ContactId = :contactId
                        AND (status =: SYSTEM.LABEL.Open OR status=:
                        SYSTEM.LABEL.New)
                        AND LastModifiedDate >= :compareDate
                        ORDER BY LastModifiedDate DESC
                ];
            }
        }
        catch(Exception e) {
            Logger.logException(e);
        }
        return caseList.size() > 0 ? caseList[0] : null;
    }

    public static RecordType getRecordType(String recordType){
        RecordType[] recordTypes = [
                SELECT Id
                FROM RecordType
                WHERE Name = :recordType
                LIMIT 1
        ];

        return recordTypes.size() > 0 ? recordTypes[0] : null;
    }

    public static Group getQueue(String developerName){
        Group[] groups = [SELECT Id, DeveloperName
        FROM Group
        WHERE DeveloperName = :developerName
        LIMIT 1];

        return groups.size() > 0 ? groups[0] : null;
    }

    public static String getSubject(String chatKey) {
        String subject = '';

        //review business intents to get the first utterance from the user
        for (ebotdata__Bot_Chat_Log__c chatLog : [
                SELECT ebotdata__Current_Utterance__c
                FROM ebotdata__Bot_Chat_Log__c
                WHERE ebotdata__Live_Agent_Session_Id__c = :chatKey
                ORDER BY CreatedDate ASC
        ]) {
            if (String.isNotBlank(chatLog.ebotdata__Current_Utterance__c)) {
                subject = chatLog.ebotdata__Current_Utterance__c;
                Log.push('NF_CreateCase getCaseSubject: using utterance for subject:' + subject);
                break;
            }
        }

        //if we weren't able to find an utterance from the history
        if (String.isBlank(subject)) {
            //if it's empty here, just default to 'Chatbot Case'
            subject = SYSTEM.LABEL.Chatbot_Case;
        }
        Logger.logDebug();
        if(subject.length() > 250)
            return subject.substring(0, 250);
        else 
            return subject;
        
    }

    public static LiveChatTranscript getLiveChatTranscript(String chatKey){
        Log.push('>>NF_Util.getLiveChatTranscript chatKey is ' + chatKey);

        if(String.isEmpty(chatKey)){
            Log.push('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
            return null;
        }

        List<LiveChatTranscript> listTranscripts = new List<LiveChatTranscript>();
        try {
            listTranscripts = [SELECT Id, CaseId, Status, ContactId, AccountId, Subject__c
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey];
        }
        catch(Exception e){
            Logger.logException(e);
        }
        Logger.logDebug();
        return listTranscripts.size() > 0 ? listTranscripts[0] : null;
    }

    public static boolean associateTranscriptWithCase(LiveChatTranscript transcript, String caseId, String contactId) {
        Log.push('Associating Transcript with Case: ' + caseId);

        boolean result = false;

        if (transcript != null && String.isNotEmpty(caseId)) {
            transcript.caseId = caseId;
            try {
                //transcript.caseId = caseId;
                Case caseToLink = [SELECT CaseNumber, SourceId, Description, Subject
                FROM Case
                WHERE Id = :caseId
                LIMIT 1];
                Log.push('Associating Case #' + caseToLink.CaseNumber + ' to transcript ' + transcript.id);
                caseToLink.LiveChatTranscripts.add(transcript);
                caseToLink.SourceId = transcript.Id;
                if(String.isNotBlank(contactId)) {
                    transcript.ContactId = contactId;
                }
                Log.push('updating transcript :****'+ transcript);
                transcript.Subject__c = caseToLink.Description;
                update transcript;
                Log.push('updating case :****'+ caseToLink);
                update caseToLink;
                Logger.logDebug();
                result = true;
            }
            catch (Exception e) {
                //NF_EinsteinBotLogger.populatedLog(e);
                Logger.logException(e);
                Logger.logDebug();
                return false;
            }
        }

        return result;
    }

    @Future
    public static void associateCaseWithSession(String chatKey, String caseId) {
        Log.push('NF_CreateCase associateCaseWithSession: chatKey=' + chatKey);

        if (String.isNotBlank(chatKey)) {
            ebotdata__Bot_Session__c session = NF_Util.getBotSession(chatKey);
            Log.push('NF_CreateCase associateCaseWithSession: session=' + session);

            if (session != null && String.isNotBlank(caseId)) {
                session.ebotdata__Case__c = caseId;
                Log.push('NF_CreateCase associateCaseWithSession: ebotdata__Case__c=' + session.ebotdata__Case__c);

                update session;
            }
        }
        Logger.logDebug();
    }

    public static ebotdata__Bot_Session__c getBotSession(String chatKey){
        ebotdata__Bot_Session__c[] botSessions = [SELECT Id, Brand__c
        FROM ebotdata__Bot_Session__c
        WHERE ebotdata__Live_Agent_Session_Id__c = :chatKey
        LIMIT 1];
        return botSessions.size() > 0 ? botSessions[0] : null;
    }

    public static Account createCustomer(String firstName, String lastName, String emailId) {
        try{
            //Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account newPersonAccount = new Account(
                    FirstName__c = firstName,
                    LastName__c = lastName,
                    AccountEmail__c = emailId,
                    Name = firstName + ' ' + lastName
                    //RecordTypeId = personAccRecordTypeId
            );
            Log.push('Inserting account'+ newPersonAccount);
            insert newPersonAccount;
            Logger.logDebug();
            return newPersonAccount;
        }
        catch(Exception e) {
            Logger.logException(e);
        }
        return null;

    }

    public static Contact createContact(String firstName, String lastName, String emailId, String brandId) {
        if(String.isBlank(firstName))
            firstName = SYSTEM.LABEL.UNKNOWN1;
        if(String.isBlank(lastName))
            lastName = SYSTEM.LABEL.UNKNOWN1;
        try{
            Contact contact = new Contact(
        FirstName = firstName,
        LastName = lastName,
        Email = emailId,

                    Brand_Id__c = brandId
        //RecordTypeId = personAccRecordTypeId
        );
        Log.push('Inserting contact'+ contact);
        insert contact;
        Logger.logDebug();
        return contact;
        }
        catch(Exception e) {
        Logger.logException(e);
        }
    return null;

}

    public Static String getBrandId(String brand) {
        List<Brand_Setting__mdt> configs = new List<Brand_Setting__mdt>();
        if(!String.isBlank(brand))
            try{
                configs = [SELECT Brand_Id__c
                FROM Brand_Setting__mdt
                WHERE Label = :brand];
            }catch(Exception e) {
                Logger.logException(e);
            }
        return configs[0].Brand_Id__c;
    }
}