/**
 * Created by bryananderson on 10/11/19.
 */

@isTest
private class DeleteOrphanedFilesBatchTest {
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

    private static void TestData()
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
        //TestData();
        test.startTest();
        id BatchId = Database.executeBatch(new DeleteOrphanedFilesBatch());
        test.stopTest();

    }
}