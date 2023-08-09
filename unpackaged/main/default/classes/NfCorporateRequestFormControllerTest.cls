@isTest(isParallel=false)
public class NfCorporateRequestFormControllerTest {
    
    /* This will need to be deprecated once refactoring happens */
    @testSetup static void setupTest() {
		GenericRecords__c gr = new GenericRecords__c();

        Contact con  = new Contact();
        con.LastName = 'MrTestAlot';
        insert con;
        gr.recordId__c = con.Id;
        gr.Name = Constants.privacyContactGenericRecordSettingName;
        insert gr;
	}
    
    @isTest
    private static void uploadFileTest(){
        
        Case ca = new Case();
        ca.Origin = 'Web';
        ca.SuppliedEmail = 'foo@example.pvh.com';
        insert ca;
        
        Test.startTest();
        String caseId = NfCorporateRequestFormController.uploadFile((string) ca.Id, 'thisisatestfile', 'thisisatestfile' );
        Test.stopTest();
        
        System.assert(!String.isEmpty(caseId));
    }
    
    @isTest
    private static void retrieveFormConfigurationEmptyTest(){
        
        Test.startTest();
        List<Corporate_Form_Configuration__c> corporateFormConfigurationList = NfCorporateRequestFormController.retrieveFormConfiguration();
        Test.stopTest();
        
        System.assert(corporateFormConfigurationList.size() == 0, ' We ecpected to get the configruation list empty. Did something change with the class');
    }
    
    @isTest
    private static void retrieveFormConfigurationCreatedDataTest(){
        
        Corporate_Form_Configuration__c cfc = new Corporate_Form_Configuration__c();
        cfc.BusinessGroup__c = 'TUG';
        insert cfc;
        
        Test.startTest();
        List<Corporate_Form_Configuration__c> corporateFormConfigurationList = NfCorporateRequestFormController.retrieveFormConfiguration();
        Test.stopTest();
        
        System.assert(corporateFormConfigurationList.size() != 0, 'We inserted a corporate form request record but our method did not retrieve it');
    }
    
    @isTest
    private static void retrieveFieldsTest(){
        
        Test.startTest();
        List<String>  fields = NfCorporateRequestFormController.retrieveFields();
        Test.stopTest();
        
        System.assert(fields.size() != 0, 'The retrieved list of fields for the case object came empty. Permission issues?');
    }
    
    @isTest
    private static void retrieveFieldsApiAndLabelTest(){
        
        Test.startTest();
        List<sObjectUtils.FieldsLabelAndName>  fields = NfCorporateRequestFormController.retrieveFieldsApiAndLabel();
        Test.stopTest();
        
        System.assert(fields.size() != 0, 'The retrieved list of fields for the case object came empty. Permission issues?');
    }
    
        @isTest
    private static void retreiveRecordTypeTest(){
        
        Test.startTest();
        String result = NfCorporateRequestFormController.retreiveRecordType('Corporate Request');
        Test.stopTest();
        
        System.assert(!String.isEmpty(result), 'We attempted to retieve Corporate Request Record type, but either it does not exists or the name has changed.');
    }
    
    @isTest
    private static void createCaseTest(){
        
        Case c = new case();
		c.Subject = 'case subject';
		c.description = 'test description';
        c.Origin = 'Web';
        c.SuppliedEmail = 'foo@example.pvh.com';
        
        String jsonStr = Json.serialize(c);
        
        Test.startTest();
        Map<String,String> result = NfCorporateRequestFormController.createCase(jsonStr,'Corporate Request');
        Test.stopTest();
        
        System.assert(result.get('CASENUMBER') != '');
        System.assert(result.get('CASEID') != '');
        System.assert(result.get('THANKYOUMESSAGE') != '');
    }

    @isTest
    private static void saveFilesTest(){
        
        Case ca = new Case();
        ca.Origin = 'Web';
        ca.SuppliedEmail = 'foo@example.pvh.com';
        insert ca;
       
        List<Object> filesToInsert = new List<Object>();
        
        NfCorporateRequestFormController.FileInfo fi = new NfCorporateRequestFormController.FileInfo();
        fi.Title = 'Title';
        fi.VersionData = Blob.valueOf('This is version data');

		filesToInsert.add( (object) fi );  
        
        test.startTest();
        list<Id> listOfIds = NfCorporateRequestFormController.saveFiles((List<Object>) filesToInsert, ca.Id);
        test.stopTest();
        
        System.assert(!listOfIds.isEmpty(),'Files were not inserted properly');
    }
}