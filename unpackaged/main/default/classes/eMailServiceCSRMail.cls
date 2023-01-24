global class eMailServiceCSRMail implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          String CsId = email.subject.replace('Sandbox: ','');
          //String CsId ='5002C00000BSnkN';
          System.debug('Email Subject is'+ CsId+'123');
          Map<String, String> params = new Map<String, String>();
          params.put('in_caseid',CsId);
          Flow.Interview.CSR_Update_Email_in_Contact flow1 = new Flow.Interview.CSR_Update_Email_in_Contact(params);
          flow1.start();
          
          return result;
      }
  }