/**
 * Created by apoorvrajput on 9/14/20.
 */
public with sharing class NF_CreateCase{
    public static final String RECORD_TYPE = SYSTEM.LABEL.Chat_Case;
    public static final String STATUS = SYSTEM.LABEL.New;
    //public static final String QUEUE_NAME = 'Calvin_Klein_Chat_Priority';
    public class Input{
        @InvocableVariable(required = true)
        public String chatKey;
        @InvocableVariable(required = false)
        public String firstName;
        @InvocableVariable(required = false)
        public String lastName;
        @InvocableVariable(required = true)
        public String email;
        @InvocableVariable(required = true)
        public String brand;
        @InvocableVariable(required = false)
        public String orderNumber;
        @InvocableVariable(required = true)
        public String reason;
        @InvocableVariable(required = false)
        public String accountId;
        @InvocableVariable(required = false)
        public String contactId;
        @InvocableVariable(required = false)
        public Boolean existingCase;
        @InvocableVariable(required = false)
        public String caseId;
        @InvocableVariable(required = false)
        public Boolean agentAvailable;
    }

    public class Output{
        @InvocableVariable(required = false)
        public String caseNumber;
        @InvocableVariable(required = false)
        public Boolean newCase;
    }

    @InvocableMethod(label = 'Neuraflash - Create Case')
    public static List<Output> createCase(List<Input> input){
        List<Output> result = new List<Output>();
        String chatKey = input[0].chatKey;
        Output out = new Output();
        Log.push('Input to case createion is :' + input[0].toString());
        Log.push('>>NF_Util.getLiveChatTranscript chatKey is: ' + chatKey);

        if (String.isEmpty(chatKey)){
            Log.push('>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty');
            Logger.logDebug();
            return null;
        }


        LiveChatTranscript liveChatTranscript = NF_Util.getLiveChatTranscript(chatKey);
        Log.push('case id::' + liveChatTranscript.CaseId);


        Case newCase;
        if (input[0].existingCase != null){
            if (input[0].existingCase){
                // don't create a new case
                newCase = [SELECT AccountId, ContactId, OwnerId, Origin, RecordTypeId, Subject, Description, emailToAddress__c, Id, SourceId, CaseNumber, Channel__c
                           FROM Case
                           WHERE Id = :liveChatTranscript.CaseId];
            }
        } else{
            // create a new case
            newCase = new Case();
            newCase.ContactId = input[0].contactId;
        }
        newCase.Channel__c = NF_Util.channelMapping.get(input[0].brand);

        if (input[0].agentAvailable != null)
            if (!input[0].agentAvailable){
                String queueDevName;
            //RC 7.13 Updating to assign to brand specific queue. Related to defect NASSC#3370
            if (Input[0].brand == SYSTEM.LABEL.Calvin_Klein){
                queueDevName = SYSTEM.LABEL.Calvin_Klein_Ecomm;
            }
            if (Input[0].brand == SYSTEM.LABEL.Tommy_Hilfiger){
                queueDevName = SYSTEM.LABEL.Tommy_Hilfiger_eComm;
            }
            Group caseQueue = NF_Util.getQueue(queueDevName);
            Log.push('Case Queue is :' + caseQueue);
            if (caseQueue != null){
                Log.push('assining casequeue :' + caseQueue);
                newCase.OwnerId = caseQueue.Id;
            }
        }

        Log.push('case is::' + newCase);
        RecordType rt = NF_Util.getRecordType(SYSTEM.LABEL.Support_Case1);
        // Log.push('RecordType is :'+ rt.toString());
        if (rt != null){
            newCase.recordTypeId = rt.id;
        }

        newCase.Origin = NF_Util.ORIGIN;
        newCase.Subject = NF_Util.getSubject(chatKey);
        //newCase.Customer_Email__c = input[0].email;
        if (String.isNotBlank(input[0].orderNumber))
            if (!input[0].orderNumber.contains('know it'))
                newCase.Order_Number__c = input[0].orderNumber;
            newCase.emailToAddress__c = input[0].email;
        if (String.isNotEmpty(input[0].reason)){
            if (input[0].reason.length() > 250)
                newCase.Description = input[0].reason.substring(0, 250);
            else{
                newCase.Description = input[0].reason;
            }

        }
        newCase.Brand__c = NF_Util.getBrandId(input[0].brand);
        if (String.isBlank(newCase.ContactId)){
            // create a new contact
            Contact contact = NF_Util.createContact(input[0].firstName, input[0].lastName, input[0].email, newCase.Brand__c);
            newCase.ContactId = contact.Id;
            // newCase.Contact = contact;
        }
        newCase.SourceId = liveChatTranscript.Id;
        Log.push('>> Upserting new case: ' + newCase);
        Output CreatedCase = new Output();
        if (input[0].existingCase != null){
            if (input[0].existingCase){
                update newCase;
                CreatedCase.newCase = false;
            }
        } else{
            insert newCase;
            CreatedCase.newCase = true;
        }

        Case CreatedCaseNumber = [SELECT CaseNumber
                                  FROM Case
                                  WHERE Id = :newCase.id];
        Log.push('New Case Number: ' + CreatedCaseNumber.CaseNumber);
        CreatedCase.caseNumber = CreatedCaseNumber.CaseNumber;

        result.add(CreatedCase);

        if (liveChatTranscript != null){
            //newCase.SourceId = liveChatTranscript.Id;
            NF_Util.associateTranscriptWithCase(liveChatTranscript, newCase.id, newCase.ContactId);
        }
        Logger.logDebug();
        return result;
    }

}