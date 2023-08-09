/**
 * Created by bryananderson on 2019-09-09.
 */
@isTest
private class pvhPrechatUISnapinControllerTest {

    @isTest
    static void lcdTestEmptyString() {
        Test.startTest();

        EmbeddedServiceDetail esdTest = pvhPrechatUISnapinController.getEmbeddedServiceDetailRecord('');
        System.assertEquals(null, esdTest);

        Test.stopTest();
    }

    @isTest
    static void lcdTestBadDate() {
        Test.startTest();
		List<LiveChatDeployment> lcdList = [SELECT DeveloperName,Id FROM LiveChatDeployment];
        System.debug('lcdList'+lcdList);
        EmbeddedServiceDetail esdTest = pvhPrechatUISnapinController.getEmbeddedServiceDetailRecord(lcdList[0].Id);
        System.assertNotEquals(null, esdTest);

        Test.stopTest();
    }
}