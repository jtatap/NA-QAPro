@IsTest
public class NF_CaseTriggerHelperTest {
	@testsetup
    static void makedata(){
        Group gp = new Group();
        gp.Name = 'RTR Request';
        insert gp; 
        
        OrgWideEmailAddress owa = [Select DisplayName From OrgWideEmailAddress Limit 1];
        
        Account brandAccount = new Account();
        brandAccount.Name = 'Calvin Klein';
        brandAccount.RecordTypeId = Constants.brandRecordTypeId;
        brandAccount.Brand_Image_Link__c = 'foo.bar';
        brandAccount.Brand_Privacy_Form_Link__c = 'boo.far';
        brandAccount.Brand_Privacy_OWA_Name__c = owa.DisplayName;
        brandAccount.Privacy_Escalation_Email__c = 'foo@example.com';
        insert brandAccount;

        Contact brandOwner = new Contact();
        brandOwner.accountId = brandAccount.Id;
        brandOwner.RecordTypeId = Constants.dataOwnerContactRecordTypeId;
        brandOwner.firstName = 'foo';
        brandOwner.LastName = 'Bar';
        brandOwner.Email = 'mrfoobar@example.com';
        brandOwner.System_Type__c = Constants.dataOwnerSupplemental;
        brandOwner.Additional_Email_1__c = 'foo@example.com';
        brandOwner.Additional_Email_2__c = 'foo@example.com';
        brandOwner.Additional_Email_3__c = 'foo@example.com';
        brandOwner.Additional_Email_4__c = 'foo@example.com';
        brandOwner.Brand_Id__c='2';
        insert brandOwner;

        Account acc = new Account();
        acc.Name = 'generic Account';
        insert acc;

        Contact con = new Contact();
        con.email = 'foo@example.com';
        con.lastName = 'generic contact';
        con.AccountId = acc.id;
        con.Brand_Id__c='2';
        insert con;

        GenericRecords__c genRec = new GenericRecords__c(
            Name = Constants.privacyContactGenericRecordSettingName,
            recordId__c = con.Id
        );
        insert genRec;
    }
    
    @IsTest
    static void testAfterUpdate(){
		Case cs = new Case();
        cs.Supplied_Last_Name__c = 'TESTING';
        cs.SuppliedEmail = 'test@test.com';
        cs.Origin = 'Phone';
        insert cs;
		cs.Brand__c = '2';
        cs.SuppliedPhone = '9988998899';
        cs.status = 'Resolved';
        cs.Sub_Type__c = 'Rectify My Data';
        cs.R2R_Email_UserConfirmation__c = 'Confirmed';
        update cs;
    }
    
    @IsTest
    static void test234MethodTest(){
     NF_CaseTriggerHelper.test234Method();
     //repeat the same for the rest of classes.
  }  
}