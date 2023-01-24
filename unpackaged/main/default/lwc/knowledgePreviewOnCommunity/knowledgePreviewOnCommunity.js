import { LightningElement, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getArticleContent from '@salesforce/apex/KnowledgeArticlePreviewController.getArticleContent';

export default class KnowledgePreviewOnCommunity extends LightningElement {

    currentPageReference = null; 
    urlStateParameters = null;
 
    
    articleID = null; /* Params from Url */
    content = null;
    header;
 
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
 
    setParametersBasedOnUrl() {
       this.articleID = this.urlStateParameters.articleID || null;
       getArticleContent({articelID: this.articleID} )
       .then(result => {
           console.log('Result ***');
           let article = result;
        this.content = article.Content__c;
        this.header = article.Title;
        console.log('ARTICLE CONTENT ***',this.content);

    })
       
    }
}