/**
 * @class:       BrandNamePicklistTest
 * @JIRA:        NASSC-25, NASSC-354
 * @description: Test Class for BrandNamePicklist class.
 */ 
@isTest
public class BrandNamePicklistTest {
	@isTest 
    static void getValuesTest() 
    {
        BrandNamePicklist obj = new BrandNamePicklist();
        obj.getValues();
    }
}