@isTest
public class requestwrapperTest {

    @isTest
    static void testrequestwrapper(){
        Test.startTest();
        requestwrapper rw = new requestwrapper();
        Test.stopTest();
        System.assert(rw!=null);
    }
}