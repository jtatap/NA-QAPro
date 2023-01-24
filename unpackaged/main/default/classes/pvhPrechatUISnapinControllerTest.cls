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

        EmbeddedServiceDetail esdTest = pvhPrechatUISnapinController.getEmbeddedServiceDetailRecord('bad data');
        System.assertEquals(null, esdTest);

        Test.stopTest();
    }
}