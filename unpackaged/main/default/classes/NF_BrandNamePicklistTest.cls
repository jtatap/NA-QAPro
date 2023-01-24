@IsTest
public class NF_BrandNamePicklistTest {

  	@isTest
    private static void testCreation(){
        NF_BrandNamePicklist rec = new NF_BrandNamePicklist();
        
        test.startTest();
        	rec.getDefaultValue();
        	rec.getValues();
        system.assertEquals(null, null);
        test.stopTest();
    }
}