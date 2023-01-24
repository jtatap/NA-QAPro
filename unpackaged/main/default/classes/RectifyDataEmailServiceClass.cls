global class RectifyDataEmailServiceClass implements Messaging.InboundEmailHandler{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String CsId = email.subject.replace('Sandbox: ','');
        system.debug('email bdy'+email.plainTextBody);
        updateContact(email.plainTextBody);
        Contact con = (Contact)JSON.deserialize(email.plainTextBody, contact.class);
        System.debug('Email Subject is'+ CsId+'123');
        Map<String, String> params = new Map<String, String>();
        params.put('in_caseid',CsId);
        /*Contact con = new Contact();
        con.Id=CsId;*/
        //update con;
        return result;
        
    }
    
    @future
    public static void updateContact(string contactStr){
        system.debug('contactStr**'+contactStr);
        Contact con = (Contact)JSON.deserialize(contactStr, contact.class);
        update con;
    }
}