/**
* @author 	    : NeuraFlash, LLC
* @date 	    : 06/07/2021
* @description 	: Retreives the records of tiles.
*===========================================================
* Ver    Date          Author			Modification
*===========================================================
* 1.0    06/07/2021    Luis Rocha		Initial Version
*/
public without sharing class NF_TilesController {
    @AuraEnabled(cacheable=true)
    public static List<NF_Contact_Tiles__mdt> getTiles(){
        try {
            List<NF_Contact_Tiles__mdt> retreivedTiles  = [SELECT Action__c,
            ButtonClass__c,
            ComponentKey__c,
            HTML_Content__c,
            LinkToOpen__c,
            SortOrder__c 
            FROM NF_Contact_Tiles__mdt];
            return retreivedTiles;
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }
}