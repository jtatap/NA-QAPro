/*****************************************************************************************
 * @Description: Apex Class to check if the Loyalty is applicable for Case->Contact->Brand
 * @Author      : Rounak P
 * @Date          : 25 Feb 2020
 * @JIRA          : NASSC-1472
 *
 *****************************************************************************************/
public without sharing class A1_MergeLoyaltyAccApexController{
    @AuraEnabled
    public static Boolean checkIsLoyaltyApplicable(Id recordId){
        Boolean isLoyaltyApplicable = false;
        try{
            Case getCase = [Select Id, Contact.Brand_Id__c, PendingPointsAdjustment__c
                            from Case
                            where Id = :recordId];
            List<LoyaltySettings__mdt> loyaltyData = [Select Id, IsLoyaltyApplicable__c
                                                      from LoyaltySettings__mdt
                                                      WHERE BrandId__c = :getCase.Contact.Brand_Id__c];

            if (loyaltyData.size() > 0)
                isLoyaltyApplicable = loyaltyData[0].IsLoyaltyApplicable__c;
        } catch (Exception ex){
            Logger.logException(ex);
        }

        return isLoyaltyApplicable;
    }

}