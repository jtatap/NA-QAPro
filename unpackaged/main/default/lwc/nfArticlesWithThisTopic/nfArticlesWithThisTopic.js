import { LightningElement, api } from 'lwc';
import fetchArticlesToDisplay from "@salesforce/apex/NF_ArticlesWithThisTopicController.fetchArticlesToDisplay";

export default class NfArticlesWithThisTopic extends LightningElement {
    @api anchorColor = '';
    articlesToDisplay;

    get displayArticles(){
        return this.articlesToDisplay && this.articlesToDisplay.length > 0;
    }

    get anchorStyle(){
        return 'color: ' + this.anchorColor;
    }

    connectedCallback(){
        fetchArticlesToDisplay({fullURL: window.location.href})
        .then((response) =>{
            if(response){
                response = JSON.parse(JSON.stringify(response));
                if(response.length > 0){
                    this.articlesToDisplay = response;
                }
            }
        })
    }
}