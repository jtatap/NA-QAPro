@IsTest(isParallel=false)
public class NF_BrandNamePicklistTest {

  	@isTest
    private static void testCreation(){
        NF_BrandNamePicklist rec = new NF_BrandNamePicklist();
        
        test.startTest();
        	VisualEditor.DataRow defaultVal = rec.getDefaultValue();
        	VisualEditor.DynamicPickListRows picklistVal = rec.getValues();
        system.assertEquals(true, defaultVal!=null);
        system.assertEquals(true, picklistVal!=null);
        test.stopTest();
    }
}