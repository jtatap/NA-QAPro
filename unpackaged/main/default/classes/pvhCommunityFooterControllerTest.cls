@isTest
public class pvhCommunityFooterControllerTest {

    @isTest
    static void test_getFooterData() {
        List<Community_Footer_Items__mdt> lstMetadata = [SELECT Brand__c, Brand__r.Brand_Name__c, Name__c, Value__c,
                                                            Header__c, Item_SequenceNo__c, Open_In_New_Tab__c, Header_SequenceNo__c
                                                                FROM Community_Footer_Items__mdt 
                                                                    WHERE Brand__r.MasterLabel =: 'Calvin Klein'
                                                                        ORDER BY Header_SequenceNo__c, Item_SequenceNo__c ASC];
        
        pvhCommunityFooterController.getFooterData('Calvin Klein');
    }

    @isTest
    static void test_getFooterCopyrightAreaData() {
        List<Community_Footer_Copyright_Area_Items__mdt> lstMetadata = [SELECT Brand__c, Brand__r.Brand_Name__c, Name__c, Value__c,
                                                                            Item_SequenceNo__c, Open_In_New_Tab__c, Row_SequenceNo__c
                                                                                FROM Community_Footer_Copyright_Area_Items__mdt 
                                                                                    WHERE Brand__r.MasterLabel =: 'Calvin Klein'
                                                                                        ORDER BY Row_SequenceNo__c, Item_SequenceNo__c ASC];

        pvhCommunityFooterController.getFooterCopyrightAreaData('Calvin Klein');
    }
}