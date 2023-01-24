/**
 * @class:       CaseSourceCountryPicklistTest
 * @JIRA:        NASSC-520
 * @description: Test Class for CaseSourceCountryPicklist class.
 */ 

@isTest
public class CaseSourceCountryPicklistTest {
 	@isTest 
    static void getValuesTest() 
    {
        CaseSourceCountryPicklist obj = new CaseSourceCountryPicklist();
        obj.getValues();
    }
}