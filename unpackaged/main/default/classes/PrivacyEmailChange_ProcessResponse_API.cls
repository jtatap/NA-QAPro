@RestResource(urlMapping = '/public/v1/privacyCSR/*')
global without sharing class PrivacyEmailChange_ProcessResponse_API{
    @HttpGet
    global static void restGet(){
        RestRequest req = RestContext.request;

        //Input variables available - These must be the same as the inputs for the Flow!!
        //String in_caseid = (String) req.params.get('in_caseid');
        //String in_response = (String) req.params.get('in_response');
        //String in_verificationCode =  (String) req.params.get('in_verificationCode');
        String respMessage = SYSTEM.LABEL.Your_response_was_not_successfully_processed_Please_email_customer_support;
        RestResponse resp = RestContext.response;
        //added by Rishabh for 725 on 15 Feb

        Case cs = [select Id, Privacy_User_Confirmed_Date__c, CSRMailUpdateonContact__c, Resolution_Code__c, Status, CSR_Email_UserConfirmation__c, VerificationHash__c, ContactId
                   from Case
                   where Id = :req.params.get('in_caseid')];
        Contact con = [SELECT Id, CSR_Trigger_PB__c
                       FROM Contact
                       WHERE Id = :cs.ContactId];
        con.CSR_Trigger_PB__c = false;
        update con;
        if (cs.CSR_Email_UserConfirmation__c == SYSTEM.LABEL.Started && cs.CSRMailUpdateonContact__c == True){
            if (req.params.get('in_response') == SYSTEM.LABEL.Open && req.params.get('in_verificationCode') == cs.VerificationHash__c){
                cs.Privacy_User_Confirmed_Date__c = system.now();
                cs.Resolution_Code__c = SYSTEM.LABEL.User_Data_Provided;
                cs.CSR_Email_UserConfirmation__c = SYSTEM.LABEL.Confirmed;
                update cs;
            } else if (req.params.get('in_response') == SYSTEM.LABEL.Resolved && req.params.get('in_verificationCode') == cs.VerificationHash__c){
                cs.Privacy_User_Confirmed_Date__c = system.now();
                cs.Resolution_Code__c = SYSTEM.LABEL.Rejected_Request;
                cs.CSR_Email_UserConfirmation__c = SYSTEM.LABEL.Rejected;
                update cs;
            }

            //TODO - try/catch for Flow exception and set a clean body
            Log.push('req.params' + req.params);
            Logger.logDebug();
            //String respMessage ='';
            Flow.Interview.Update_Case_with_Cust_Data_Owner_CSR_Email flow1 = new Flow.Interview.Update_Case_with_Cust_Data_Owner_CSR_Email(req.params);
            //Flow.Interview.CSR_Update_Email_in_Contact flow1 = new Flow.Interview.CSR_Update_Email_in_Contact(req.params);
            flow1.start();

            if (flow1.getVariableValue('out_success').equals(true)){
                respMessage = SYSTEM.LABEL.Your_response_was_successfully_processed_Click_here_to_close_the_window;
                if (req.params.get('in_response') == SYSTEM.LABEL.Resolved){
                    respMessage = SYSTEM.LABEL.Thank_you_for_your_response_Please_note_that_no_changes_have_been_made_to_your;
                }
            }
            //else if (flow1.getVariableValue('out_response').equals('') == false)
            //{
            //respMessage = (String)flow1.getVariableValue('out_response');
            //respMessage = 'Thank you for your response. Please note that no changes have been made to your Account.';
            //}
        } else{
            respMessage = SYSTEM.LABEL.A_response_has_already_been_submitted_for_this_request_If_you_believe_you_are_r;
        }
        String response = '<html><head><title>PVH Privacy Request Processing</title><script type="text/javascript">' + 
                                 '    function closeCurrentTab(){ ' + 
                                 '        var conf=confirm("Are you sure, you want to close this tab?"); ' + 
                                 '        if(conf==true){ ' + 
                                 '            close(); ' + 
                                 '        } ' + 
                                 '    } ' + 
                                 '</script> ' + 
                                 '</head><body style="text-align: center;">' + 
                                 '<p><input type="button" value="' + respMessage + '" onclick="window.close()"' + '</body></html>';

        resp.responseBody = Blob.valueOf(response);

        resp.headers.put('Content-Type', 'text/html; charset=utf-8');
    }

}