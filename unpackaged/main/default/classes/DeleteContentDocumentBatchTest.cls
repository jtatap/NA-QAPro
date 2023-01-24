/**
 * Created by bryananderson on 10/7/19.
 */

/*@isTest
private class DeleteContentDocumentBatchTest {
    /*static testmethod void test() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        //cv.IsMajorVersion = true;
        //cv.FirstPublishLocationId = UserInfo.getUserId();
        //cv.ContentLocation='S';

        Test.startTest();
        Insert cv;
        Test.stopTest();
    }*/

  /*  private static void TestData()
    {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
    }

    private static testmethod void Batchtest()
    {
        //calling Test Data Method
        TestData();
        test.startTest();
        id BatchId = Database.executeBatch(new DeleteContentDocumentBatch());
        test.stopTest();

    }
}*/

//edited testClass 
@isTest
public class DeleteContentDocumentBatchTest 
{
	@testsetup
    static void setup()
    {
      list<pcify__log__c> l=[SELECT pcify__RecordId__c FROM pcify__Log__c WHERE pcify__CreditCardDetected__c = TRUE AND pcify__Object__c ='ContentVersion' ORDER BY CreatedDate DESC limit 10];
    	insert l;
        list<ContentVersion> CVl=[SELECT ContentDocumentId FROM ContentVersion limit 10];
        insert CVl;
        //list<ContentDocument> CDl=[SELECT FileType,SharingOption FROM ContentDocument];
        //insert CDl;
    }
    
    @isTest
    static void test()
    {
        Test.startTest();
        DeleteContentDocumentBatch dcbc=new DeleteContentDocumentBatch();
        Id batchId=Database.executeBatch(dcbc);
        Test.stopTest();  
    }
    
    @isTest
    static void test2()
    {
        //String sch='20 30 8 10 2 ?';
        Test.startTest();
        String jobid=System.scheduleBatch(new DeleteContentDocumentBatch(),'Schedule',5);
        Test.stopTest();
    }
}