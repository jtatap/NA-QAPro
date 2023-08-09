global class eMailServiceCSRMail implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          Log.push('email.subject'+email.subject);
          String CsId = email.subject.replace('Sandbox: ','');
          //String CsId ='5002C00000E6fgjQAB';
          Log.push('Email Subject is'+ CsId+'123');
          Map<String, String> params = new Map<String, String>();
          params.put('in_caseid',CsId);
          Log.push('params are'+params);
          Logger.logDebug();
          Flow.Interview.CSR_Update_Email_in_Contact flow1 = new Flow.Interview.CSR_Update_Email_in_Contact(params);
          flow1.start();
          
          return result;
      }
  }