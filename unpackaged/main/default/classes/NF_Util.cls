/**
 * Created by apoorvrajput on 9/10/20.
 */

public with sharing class NF_Util {

    public static final String ORIGIN = 'Chat';
    public static String TOMMY = 'Tommy Hilfiger';
    public static String CALVIN = 'Calvin Klein';
    public static String IZOD = 'IZOD';
    public static String VAN = 'Van Heusen';
    public static final String RECORD_TYPE = 'Chat Case';

    public static String getLastBusinessIntent(String chatKey){
        String lastBusinessIntent = '';
        try {
            ebotdata__Bot_Session__c botSession = NF_Util.getBotSession(chatKey);
            System.debug('>>NF_Util.getFirstUserInput botSession=' + botSession);

            if (botSession != null) {
                for (ebotdata__Bot_Chat_Log__c chatLog : [
                        SELECT Id, ebotdata__Intent_Name__c
                        FROM ebotdata__Bot_Chat_Log__c
                        WHERE ebotdata__Bot_Session__c = :botSession.Id
                        ORDER BY Name ASC
                        LIMIT 10
                ]) {

                    System.debug('>>NF_Util.getLastBusinessIntent: ebotdata__Intent_Name__c=' + chatLog.ebotdata__Intent_Name__c);
                    if (String.isNotEmpty(chatLog.ebotdata__Intent_Name__c) && chatLog.ebotdata__Intent_Name__c.substring(0, 3) == 'bus') {
                        lastBusinessIntent = chatLog.ebotdata__Intent_Name__c;
                        break;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception encountered: ' + e);
        }
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
            TOMMY => 'Online - Tommy.com',
            CALVIN => 'Online - CalvinKlein.com',
            IZOD => 'Online - Izod.com',
            VAN => 'Online - vanheusen.com'
    };

    public static Map<String, String> buttonMapping = new Map<String, String>{
            TOMMY => 'Tommy Prioritized Chat',
            CALVIN => 'Calvin Klein Prioritized Chat',
            IZOD => 'Partner Brands Prioritized Chat',
            VAN => 'Partner Brands Prioritized Chat'
    };

    public static Map<String, String> deploymentMapping = new Map<String, String> {
            TOMMY => 'Tommy Prioritized Chat',
            CALVIN => 'Calvin Klein Prioritized Chat',
            IZOD => 'Partner Brands Prioritized Chat',
            VAN => 'Partner Brands Prioritized Chat'
    };

    public static Map<String, String> queueMapping = new Map<String, String> {
            TOMMY => 'Tommy_Chat_Priority',
            CALVIN => 'Calvin_Klein_Chat_Priority',
            IZOD => 'Partner_Brands_Chat_Priority',
            VAN => 'Partner_Brands_Chat_Priority'
    };

    public static Brand_Setting__mdt getBrandName(String URL){
        System.debug(URL);
        String brandName = '';
        String backup = URL.toUpperCase();
        URL = URL.toUpperCase();
        URL = URL.remove('HTTPS');
        URL = URL.remove('HTTP');
        URL = URL.remove('//');
        URL = URL.substringBefore('/');
        System.debug(URL +', ' +backup);
        // this is a test domain.
        if(URL.contains('NEURAFLASH') || URL.contains('PVHSERVICECLOUD')) {
            URL = backup;
            System.debug('USING backup'+ URL +', ' +URL.contains('CALVIN'));

        }
        if(URL.contains('TH') || URL.contains('TOMMY') || URL.contains('HILFIGER'))
            brandName = 'Tommy_Hilfiger';
        else if(URL.contains('CK') || URL.contains('CALVIN') || URL.contains('KLEIN'))
            brandName = 'Calvin_Klein';
        else if(URL.contains('IZOD') || URL.contains('IZOD') || URL.contains('IZ'))
            brandName = 'Izod';
        else if(URL.contains('VH') || URL.contains('HEUSEN') || URL.contains('VAN'))
            brandName = 'Van_Heusen';

        List<Brand_Setting__mdt> configs = new List<Brand_Setting__mdt>();
        try{
            configs = [SELECT Id, Community_Name__c, Brand_Id__c, Label, Brand_Email__c, Brand_Phone__c, Shipping_Questions_URL__c, Covid_URL__c, Return_Questions_URL__c, Return_URL__c, Product_Questions_URL__c, Promotions_URL__c, Order_Status_URL__c
            FROM Brand_Setting__mdt
            WHERE DeveloperName = :brandName];
        }
        catch(Exception e) {
            System.debug('Exception encountered: ' + e);
        }
        return configs.size() > 0 ? configs[0] : null;
    }

    public static void insertSession(String chatKey, String payload, String brand){
        System.debug('bot session creation started.');
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.CarouselContent__c = payload;
        session.ebotdata__Live_Agent_Session_Id__c = chatKey;
        //session.ebotdata__Live_Chat_Transcript__c = chatKey;
        session.Brand__c = brand;
        insert session;
        System.debug('bot session created');
    }

    public static User getPlatformIntegrationUser(){
        User[] users = [SELECT Id, Name FROM User WHERE Name = 'Automated Process' LIMIT 1];
        return users.size() > 0 ? users[0] : null;
    }

    public static String getDomainName(String url) {
        try {

            Url uri = new Url(url);
            String domain = uri.getHost();
            System.debug('Host is: '+ domain);
            return domain.startsWith('www.') ? domain.substring(4) : domain;
        }
        catch (Exception e) {
            System.debug('exception details :'+e.getStackTraceString());
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
                lastName = 'NA';

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
            System.debug('Exception encountered: ' + e);
        }
        return contactList.size() > 0 ? contactList[0] : null;
    }

    public static Contact getContact(String email, String accountId, String brand) {
        List<Contact> contactList = new List<Contact>();
        List<Brand_Setting__mdt> configs = new List<Brand_Setting__mdt>();
        System.debug('brand is:'+brand  + 'email is: '+email);

        if(!String.isBlank(brand))
            try{
                configs = [SELECT Brand_Id__c
                FROM Brand_Setting__mdt
                WHERE Label = :brand];
            }catch(Exception e) {
                System.debug('Exception encountered: ' + e);
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
            System.debug('Returning contact list: '+contactList);
        }
        catch(Exception e) {
            System.debug('Exception encountered: ' + e);
        }
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
                        AND (status = 'Open' OR status='New')
                        AND LastModifiedDate >= :compareDate
                        ORDER BY LastModifiedDate DESC
                ];
            }
        }
        catch(Exception e) {
            System.debug('Exception encountered: ' + e);
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
                System.debug('NF_CreateCase getCaseSubject: using utterance for subject:' + subject);
                break;
            }
        }

        //if we weren't able to find an utterance from the history
        if (String.isBlank(subject)) {
            //if it's empty here, just default to 'Chatbot Case'
            subject = 'Chatbot Case';
        }
        if(subject.length() > 250)
            return subject.substring(0, 250);
        else 
            return subject;
        
    }

    public static LiveChatTranscript getLiveChatTranscript(String chatKey){
        System.debug('>>NF_Util.getLiveChatTranscript chatKey is ' + chatKey);

        if(String.isEmpty(chatKey)){
            System.debug('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
            return null;
        }

        List<LiveChatTranscript> listTranscripts = new List<LiveChatTranscript>();
        try {
            listTranscripts = [SELECT Id, CaseId, Status, ContactId, AccountId, Subject__c
            FROM LiveChatTranscript
            WHERE ChatKey = :chatKey];
        }
        catch(Exception e){
            System.debug('Exception encountered: ' + e);
        }

        return listTranscripts.size() > 0 ? listTranscripts[0] : null;
    }

    public static boolean associateTranscriptWithCase(LiveChatTranscript transcript, String caseId, String contactId) {
        System.debug('Associating Transcript with Case: ' + caseId);

        boolean result = false;

        if (transcript != null && String.isNotEmpty(caseId)) {
            transcript.caseId = caseId;
            try {
                //transcript.caseId = caseId;
                Case caseToLink = [SELECT CaseNumber, SourceId, Description, Subject
                FROM Case
                WHERE Id = :caseId
                LIMIT 1];
                System.debug('Associating Case #' + caseToLink.CaseNumber + ' to transcript ' + transcript.id);
                caseToLink.LiveChatTranscripts.add(transcript);
                caseToLink.SourceId = transcript.Id;
                if(String.isNotBlank(contactId)) {
                    transcript.ContactId = contactId;
                }
                System.debug('updating transcript :****'+ transcript);
                transcript.Subject__c = caseToLink.Description;
                update transcript;
                System.debug('updating case :****'+ caseToLink);
                update caseToLink;
                result = true;
            }
            catch (Exception e) {
                //NF_EinsteinBotLogger.populatedLog(e);
                System.debug('Exception encountered while updating transcript: ' + e);
                System.debug('Line: ' + e.getLineNumber());
                System.debug('Trace: ' + e.getStackTraceString());
                return false;
            }
        }

        return result;
    }

    @Future
    public static void associateCaseWithSession(String chatKey, String caseId) {
        System.debug('NF_CreateCase associateCaseWithSession: chatKey=' + chatKey);

        if (String.isNotBlank(chatKey)) {
            ebotdata__Bot_Session__c session = NF_Util.getBotSession(chatKey);
            System.debug('NF_CreateCase associateCaseWithSession: session=' + session);

            if (session != null && String.isNotBlank(caseId)) {
                session.ebotdata__Case__c = caseId;
                System.debug('NF_CreateCase associateCaseWithSession: ebotdata__Case__c=' + session.ebotdata__Case__c);

                update session;
            }
        }
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
            System.debug('Inserting account'+ newPersonAccount);
            insert newPersonAccount;
            return newPersonAccount;
        }
        catch(Exception e) {
            System.debug('Exception encountered: ' + e);
        }
        return null;

    }

    public static Contact createContact(String firstName, String lastName, String emailId, String brandId) {
        Id contactEmailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        if(String.isBlank(firstName))
            firstName = 'UNKNOWN';
        if(String.isBlank(lastName))
            lastName = 'UNKNOWN';
        try{
            Contact contact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = emailId,
            Brand_Id__c = brandId,
            RecordTypeId = contactEmailRecordTypeId
            );//Added RecordTypeId for Incident INC0781631 - Duplicate contact created
        System.debug('Inserting contact'+ contact);
        insert contact;
        return contact;
        }
        catch(Exception e) {
        System.debug('Exception encountered: ' + e);
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
                System.debug('Exception encountered: ' + e);
            }
        return configs[0].Brand_Id__c;
    }
}