import { LightningElement, track, api, wire } from 'lwc';
import getTopicList from "@salesforce/apex/NF_GetTopicFromArticleController.getTopicList";
import {consolePrintList} from 'c/nfConsoleUtil';

export default class NfAdobeAnalyticArticle extends LightningElement {
    @api recordId = "";
    @track loaded = false;
    @track topicName ="";
    @track allTopicList =[];

    connectedCallback() {
        console.log('Article Id>>>>'+this.recordId);
        this.loaded = true;
        if(this.recordId.startsWith('ka') && this.recordId !==undefined && this.recordId !=='') {
            getTopicList({
                recordId : this.recordId,
            })
            .then(result => {
                consolePrintList(result, "Result Data:");
                this.allTopicList = result;
                this.topicName = result[0];
                console.log(this.topicName);
    
            })
            .catch( error => {
                console.log('error');
            })
            .finally(() => {
                let x = window.dispatchEvent(new CustomEvent("myclick", { detail: { topic: this.topicName }}));
                console.log('NF_ArticleDetail Page loadded:' + x);
            });
        }
        else {
            let x = window.dispatchEvent(new CustomEvent("myclick", { detail: { topic:''}}));
            console.log('Other Pages loadded:' + x);
        }
        
    }

    
}