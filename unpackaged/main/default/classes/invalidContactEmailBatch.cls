global class invalidContactEmailBatch implements Database.Batchable<sObject>{
 global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID,Email FROM Contact WHERE Email!='' AND (NOT Email LIKE '%example.com')ORDER By ID ASC limit 50000]); 
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        
        List<Contact> conList = new List<Contact>();
        Set<String> emailSet = new Set<String>();

        for(Contact con:(List<Contact>)scope)
        {
            

            Contact c =con;
            if(c.Email.length()<56){ 
            if(!c.Email.contains('example')){
                system.debug('inside contact****');
                emailSet.add(c.Email);
                c.Email=c.Email.replace('@','=')+'@example.com';
                conList.add(c); 
            }
            }    
              
        }
        if(conList.size()>0)
        {
         
            Update conList;
           
        }
            
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}