import { LightningElement,api,track,wire } from 'lwc';
import getCommunityURL from '@salesforce/apex/KnowledgeArticlePreviewController.getCommunityURL';

export default class KnowledgeArticlePreview extends LightningElement {

  @api recordId;
  error;
  
  handleClick(){
      console.log('ID',this.recordId);
      getCommunityURL({recordId:this.recordId})
      .then(result => {
        console.log('Res',result);
        let url =  result;
        window.open(url,'_blank');
        

    })
    .catch(error => {
        this.error = error;
        console.log('ERROR ',this.error);
    });
        

      
  }
  
}