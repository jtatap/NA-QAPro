public with sharing class KnowledgeArticlePreviewController {
    
    @AuraEnabled
    public static string getCommunityURL(String recordId){
        try {
            Knowledge__kav article = [select id , Brand__c ,UrlName,VersionNumber from Knowledge__kav where id =:recordId  ];
            System.debug('ARTICLE'+article);
            String urlName = article.urlName;
            String brand = article.Brand__c;
            String URL = '';
            switch on brand {
                when 'Calvin Klein' {
                    Knowledge__DataCategorySelection catSelection = [select DataCategoryGroupName,DataCategoryName,ParentId from Knowledge__DataCategorySelection 
                                                                     WHERE ParentId=:recordId];
                    System.debug('ARTICLE CAT'+catSelection);
                    String dataCategoryName = catSelection.DataCategoryName;
                    Boolean CA1 = dataCategoryName.contains('Calvin_CA');
                    Boolean CA2 = dataCategoryName.endsWith('_CA');
                    
                    // If string contains either of above sub string then article needs to be previewed on US Community 
                    if(CA1 || CA2){
                       URL = System.Label.Calvin_CA_URL+'custom-article-preview?articleID='+article.Id;
                        
                    }
                    else{
                        
                        URL =System.Label.Calvin_US_URL+'custom-article-preview?articleID='+article.Id;
                    }
                }	
                when 'Tommy Hilfiger' {	
                    URL = System.Label.Tommy_URL+'custom-article-preview?articleID='+article.Id;
                }               
            }
        
            return URL;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
        
        
    }
    
      @AuraEnabled
    public static Knowledge__kav getArticleContent(String articelID){
        system.debug('ARTLE ID *****'+articelID);
        Knowledge__kav article = [select id , Brand__c ,UrlName,Content__c , KnowledgeArticleId ,Title from Knowledge__kav where Id =:articelID];
       system.debug('ARTICLe ***'+article);
        return article;
        
        
    }
}