@RestResource(urlMapping='/public/v1/privacyCSR/*')
global without sharing class PrivacyEmailChange_ProcessResponse_API {


    @HttpGet
    global static void restGet() {
		RestRequest req = RestContext.request;
		
		//Input variables available - These must be the same as the inputs for the Flow!!
		//String in_caseid = (String) req.params.get('in_caseid');
		//String in_response = (String) req.params.get('in_response');
		//String in_verificationCode =  (String) req.params.get('in_verificationCode');
		String respMessage = 'Your response was not successfully processed. Please email customer support';
        RestResponse resp = RestContext.response;
		Case cs = [select Id, Privacy_User_Confirmed_Date__c,CSRMailUpdateonContact__c,Resolution_Code__c,Status,CSR_Email_UserConfirmation__c,VerificationHash__c from Case where Id=:req.params.get('in_caseid')];
        if (cs.CSR_Email_UserConfirmation__c =='Started' && cs.CSRMailUpdateonContact__c == True){
            if (req.params.get('in_response') == 'Open' && req.params.get('in_verificationCode') == cs.VerificationHash__c) {
                cs.Privacy_User_Confirmed_Date__c=system.now();
                cs.Resolution_Code__c='User Data Provided';
                cs.CSR_Email_UserConfirmation__c ='Confirmed';
                update cs;
            }
            else if (req.params.get('in_response') == 'Resolved' && req.params.get('in_verificationCode') == cs.VerificationHash__c) {
                cs.Privacy_User_Confirmed_Date__c=system.now();
                cs.Resolution_Code__c='Rejected Request';
                cs.CSR_Email_UserConfirmation__c ='Rejected';
                update cs;
            }
            
            //TODO - try/catch for Flow exception and set a clean body
            
            //String respMessage ='';
            Flow.Interview.Update_Case_with_Cust_Data_Owner_CSR_Email flow1 = new Flow.Interview.Update_Case_with_Cust_Data_Owner_CSR_Email(req.params);
            //Flow.Interview.CSR_Update_Email_in_Contact flow1 = new Flow.Interview.CSR_Update_Email_in_Contact(req.params);
            flow1.start();
    
            if (flow1.getVariableValue('out_success').equals(true)){
               respMessage = 'Your response was successfully processed. Click here to close the window';
                if (req.params.get('in_response') == 'Resolved'){
                    respMessage = 'Thank you for your response. Please note that no changes have been made to your Account.';
                }
            }
            //else if (flow1.getVariableValue('out_response').equals('') == false)
            //{
              //respMessage = (String)flow1.getVariableValue('out_response');
              //respMessage = 'Thank you for your response. Please note that no changes have been made to your Account.';
            //}
        }
        else{
                respMessage ='A response has already been submitted for this request. If you believe you are receiving this message in error please contact Customer Service';
            }
		String response =  '<html><head><title>PVH Privacy Request Processing</title><script type="text/javascript">' +
		'    function closeCurrentTab(){ ' +
		'		var conf=confirm("Are you sure, you want to close this tab?"); ' +
		'		if(conf==true){ ' +
		'			close(); ' +
		'		} ' +
		'	} ' +
		'</script> ' +
		'</head><body style="text-align: center;">' +
		'<p><input type="button" value="' + respMessage + '" onclick="window.close()"' + '</body></html>' ;

		resp.responseBody = Blob.valueOf(response);

		resp.headers.put('Content-Type', 'text/html; charset=utf-8');
		
    }   

}