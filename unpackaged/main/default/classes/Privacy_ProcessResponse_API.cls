@RestResource(urlMapping='/public/v1/privacy/*')
global class Privacy_ProcessResponse_API  {


    @HttpGet
    global static void restGet() {
		RestRequest req = RestContext.request;
		
		//Input variables available - These must be the same as the inputs for the Flow!!
		//String in_caseid = (String) req.params.get('in_caseid');
		//String in_response = (String) req.params.get('in_response');
		//String in_verificationCode =  (String) req.params.get('in_verificationCode');

		RestResponse resp = RestContext.response;
		

		Flow.Interview.updateCaseWithEmailResponse flow1 = new Flow.Interview.updateCaseWithEmailResponse(req.params);
		flow1.start();
		


		//TODO - try/catch for Flow exception and set a clean body
		String respMessage = SYSTEM.LABEL.Your_response_was_not_successfully_processed_Please_email_customer_support;
		//String respMessage ='';
		if (flow1.getVariableValue('out_success').equals(true)){
		   respMessage = SYSTEM.LABEL.Your_response_was_successfully_processed_Click_here_to_close_the_window;
		}
        else if (flow1.getVariableValue('out_response').equals('') == false)
        {
          respMessage = (String)flow1.getVariableValue('out_response');
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

		resp.headers.put(SYSTEM.LABEL.ContentType, SYSTEM.LABEL.text_html_charset_utf_8);
		
    }   


}