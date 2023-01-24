/**
 * @description       : Test class for NF_BrandFormController
 * @author            :
 * @last modified on  : 08-05-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
**/
@isTest
public class NF_BrandFormControllerTest {

    public static Webform_Brands__mdt getDefault(){
        Webform_Brands__mdt bnm = new Webform_Brands__mdt();
        bnm.Brand_Name__c = 'NF Test Brand';
        bnm.Brand_Code__c = 2.0;
        bnm.Case_Success_Message__c = 'Thank you. Your case number is CASENUMBER.';
        bnm.Track_Order_At__c = 'https://track.order.com';
        bnm.Logo_URL__c = 'https://logo.com';
        bnm.Password_Reset_At__c = 'https://password.reset.com';
        bnm.Check_Order_Status_At__c = 'https://status.order.com';
        bnm.Show_Logo__c = true;
        bnm.Use_Single_Brand_Channel__c = false;
        return bnm;
    }

    @isTest
    private static void testWrapperClass(){
        NF_BrandFormController.FieldObject fob = new NF_BrandFormController.FieldObject('Name','Name__c',false,'STRING');

        Webform_Brands__mdt bnm = getDefault();

        NF_BrandFormController.BrandObject bo = new NF_BrandFormController.BrandObject(bnm);
        System.assertEquals(bo.brandCode,2);

        NF_BrandFormController.PicklistObject pob = new NF_BrandFormController.PicklistObject();
        pob.label = 'In Progress';
        pob.value = 'inProgress';
        pob.parent = 'Default';
        pob.order = 2;
        pob.information = 'The work is in progress';
        pob.show = true;

        NF_BrandFormController.FormConfig fo = new NF_BrandFormController.FormConfig();

        System.assertEquals('',NF_BrandFormController.selectOption().value);

        NF_BrandFormController.CaseAttachmentObject cob = new NF_BrandFormController.CaseAttachmentObject();
        cob.parentId = 'someRandomCaseId';
        cob.filesToLink = new List<NF_BrandFormController.FileObject>{new NF_BrandFormController.FileObject()};
            cob.filesToDelete = new List<NF_BrandFormController.FileObject>{new NF_BrandFormController.FileObject()};
                System.assertEquals('someRandomCaseId',cob.parentId);
    }

    @isTest
    private static void testCaseCreationLoyalty(){
        String caseString = '{"filesToRelate": [],"filesToDelete": [],"Brand__c": 1,"Supplied_First_Name__c": "Amit","Supplied_Last_Name__c": "Gayal","SuppliedEmail": "amitgl259@gmail.com","SuppliedPhone": "+919899902749",';
        caseString += '"Channel__c": "Tommy.com","Reason_Code__c": "Loyalty","Reason_Code_Details__c": "Edit Account Information","Tracking_Number__c": "T0021321",';
        caseString += '"Order_Number__c": "O0021321","Description": "I cannot track my order. Please help me.\\n\\n", "Type": "Privacy"}';

        String caseId = NF_BrandFormController.createCase(caseString);
        System.assertNotEquals(NULL,caseId);
    }

    @isTest
    private static void testCaseCreationProduct(){
        String caseString = '{"filesToRelate": [],"filesToDelete": [],"Brand__c": 1,"Supplied_First_Name__c": "Amit","Supplied_Last_Name__c": "Gayal","SuppliedEmail": "amitgl259@gmail.com","SuppliedPhone": "+919899902749",';
        caseString += '"Channel__c": "Tommy.com","Reason_Code__c": "Product","Reason_Code_Details__c": "Defective Merchandise","Tracking_Number__c": "T0021321",';
        caseString += '"Order_Number__c": "O0021321","Description": "I cannot track my order. Please help me.\\n\\n", "Type": "Privacy"}';

        String caseId = NF_BrandFormController.createCase(caseString);
        System.assertNotEquals(NULL,caseId);
    }

    @isTest
    static void testDocumentUpdate()
    {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test Insert',
            PathOnClient = 'Test Insert.jpg',
            VersionData = Blob.valueOf('Test Content Data to insert'),
            IsMajorVersion = true
        );
        ContentVersion contentVersionDelete = new ContentVersion(
            Title = 'Test Delete',
            PathOnClient = 'Test Delete.jpg',
            VersionData = Blob.valueOf('Test Content Data to delete'),
            IsMajorVersion = true
        );

        insert new List<ContentVersion>{contentVersionInsert,contentVersionDelete};
        list<ContentVersion> docList = [Select id,ContentDocumentId  From ContentVersion where  Title = 'Test Insert' limit 1];
        /* ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN : new List<Id>{contentVersionInsert.Id,contentVersionDelete.Id}]; */
        NF_BrandFormController.FileObject rec = new NF_BrandFormController.FileObject();
        rec.name = 'Test Insert';
        rec.documentId = docList[0].ContentDocumentId;
        String result = NF_BrandFormController.updateFileDescription(JSON.serialize(new List<NF_BrandFormController.FileObject>{rec}));
        System.assertEquals('File update completed.', result);
        System.assert(NF_BrandFormController.updateFileDescription(null).equalsIgnoreCase('No related files found.'));
    }

    @isTest
    private static void testGetFormConfig(){
        String brandName = 'Tommy Hilfiger';
        NF_BrandFormController.FormConfig fg = NF_BrandFormController.getFormConfig(brandName);
        System.assertEquals(brandName,fg.brand.brandName);

        System.assertNotEquals(NULL, NF_BrandFormController.getAllBrands());
    }
}