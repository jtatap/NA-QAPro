public class ObservationFormComponentApexController {
    
    @AuraEnabled
    public static String getCaseOrigin(Id caseId) {
        String recordTypeToSelect = '';
        Log.push('Case Id = '+caseId);
        Logger.logDebug();
        if(caseId != null) {
            Case getCaseInfo = [Select Origin, Brand__c from Case where Id=:caseId];
            //Log.push('Case Origin = '+getCaseInfo.Origin + ' AND Brand ='+getCaseInfo.Brand__c);
            Id recordTypeIdChat = Schema.SObjectType.Observation_Form__c.getRecordTypeInfosByDeveloperName().get('Chat_Observation_Form').getRecordTypeId();
            Id recordTypeIdEmailWeb = Schema.SObjectType.Observation_Form__c.getRecordTypeInfosByDeveloperName().get('Email_Observation_Form').getRecordTypeId();
            Id recordTypeIdEmailWebTrue = Schema.SObjectType.Observation_Form__c.getRecordTypeInfosByDeveloperName().get('Email_Observation_Form_True_Co').getRecordTypeId();
            Id recordTypeIdPhone = Schema.SObjectType.Observation_Form__c.getRecordTypeInfosByDeveloperName().get('Phone_Observation_Form').getRecordTypeId();
            
            
            if(getCaseInfo.Origin=='Chat' && getCaseInfo.Brand__c!='11'){
                recordTypeToSelect = recordTypeIdChat;
            }            
            else if((getCaseInfo.Origin=='Email' || getCaseInfo.Origin=='Web') && getCaseInfo.Brand__c!='11'){
                recordTypeToSelect = recordTypeIdEmailWeb;
            }            
            else if((getCaseInfo.Origin=='Email' || getCaseInfo.Origin=='Web') && getCaseInfo.Brand__c =='11'){
                recordTypeToSelect = recordTypeIdEmailWebTrue;
            }            
            else if(getCaseInfo.Origin=='Phone'){
                recordTypeToSelect = recordTypeIdPhone;
            }
            else{
                recordTypeToSelect = recordTypeIdChat;
            }            
            return recordTypeToSelect;
        }
        else{
            return null;
        }
    }
    
}