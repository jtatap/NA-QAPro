trigger ExecuteAsSFCCIntegrationUserTrigger on ExecuteAsSFCCIntegrationUser__e (after insert) {
    List<Contact> con = new List<Contact>();
    for(ExecuteAsSFCCIntegrationUser__e easiu :trigger.new){
        con.add(new Contact(Id =easiu.ContactId__c , UpdateBySFCCIntUser__c = true, Point_Balance__c=easiu.PointBalance__c));
    }
    Update con;
}