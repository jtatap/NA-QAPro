/**
* Created by bryananderson on 10/11/19.
*/

@isTest(isParallel = false)
private class DeleteOrphanedFilesBatchTest {
    /*@testSetup
    static void createdata(){

        Profile guestProfile = [SELECT Id FROM Profile WHERE UserType = 'Guest' AND Name != 'Guest License User' LIMIT 1];
        User guestUser = new User(
                ProfileId = guestProfile.Id,
                LastName = 'Test LastName',
                Alias = 'test',
                Email = 'test@example.com',
                Username = 'sajhdajkdajd@ashjdajkda.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
                );
        insert guestUser;
        //User user1 = [SELECT Id from User where UserType = 'Guest' AND LIMIT 1];
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ionicLogo.doc'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Proposal '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        
        insert conVer;


        EmailMessage emailToLog = new EmailMessage();
        emailToLog.ToAddress = 'foo@example.com';
        emailToLog.Subject = 'foo';
        emailToLog.HtmlBody = 'foo';
        emailToLog.Incoming = True;
        emailToLog.MessageDate = System.now();
        emailToLog.FromAddress = 'bar@example.com';
        insert emailToLog;

        ContentVersion conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id];
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc.ContentDocumentId;
        cDe.LinkedEntityId = guesetUser.Id; //emailToLog.Id
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        /*
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc.ContentDocumentId;
        cDe.LinkedEntityId = guestUser.Id;
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;

         */
        
        
        
    
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
        //
        Profile guestProfile = [SELECT Id FROM Profile WHERE UserType = 'Guest' AND Name != 'Guest License User' LIMIT 1];
        User guestUser = new User(
                ProfileId = guestProfile.Id,
                LastName = 'Test LastName',
                Alias = 'test',
                Email = 'test@example.com',
                Username = 'sajhdajkdajd@ashjdajkda.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
                );
        insert guestUser;
        //User user1 = [SELECT Id from User where UserType = 'Guest' AND LIMIT 1];
        

        EmailMessage emailToLog = new EmailMessage();
        emailToLog.ToAddress = 'foo@example.com';
        emailToLog.Subject = 'foo';
        emailToLog.HtmlBody = 'foo';
        emailToLog.Incoming = True;
        emailToLog.MessageDate = System.now();
        emailToLog.FromAddress = 'bar@example.com';
        insert emailToLog;
		
        User cksiteuser = [SELECT Id, Name FROM User WHERE name = 'Calvin Klein - CA Site Guest User'];
        //User cksiteuser = [SELECT Id, Name FROM User WHERE Email = 'test@example.com'];
        User admin = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' AND isActive = True LIMIT 1];
        System.runAs(admin){
            
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ionicLogo.doc'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Proposal '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        conVer.OwnerId = admin.id;
        conVer.firstPublishLocationId = admin.id;
        insert conVer;
    	List<User> guestUserList = [Select Id from user where UserType ='Guest' LIMIT 1];
        ContentVersion conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id];
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc.ContentDocumentId;
        cDe.LinkedEntityId = cksiteuser.Id;//emailToLog.Id;//cksiteuser.Id; // //emailToLog.Id
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        //insert cDe; //commented by Rishabh on 9 March
        

        }
        
        
        test.startTest();
        id BatchId = Database.executeBatch(new DeleteOrphanedFilesBatch());
        DeleteOrphanedFilesBatch dfb = new DeleteOrphanedFilesBatch();
        dfb.abcMethod();
        test.stopTest();
        
    }
}