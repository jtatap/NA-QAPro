import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SCCOrderOnBehalfOf extends NavigationMixin(LightningElement) {
    @api token;
    @api siteId;
    @api domain;
    @api shopDomain;
    @api version;
    @api recordId;
    @api caseRecordId;
    @track  upcatedCaseId;

    openPage() {

        if(this.recordId){
            this.upcatedCaseId = this.recordId;
        }else{
            this.upcatedCaseId = this.caseRecordId;
        }
        
        let xhr = new XMLHttpRequest();
        xhr.open('POST', `${this.domain}/s/${this.siteId}/dw/shop/${this.version}/sessions`, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Authorization', this.token);
        xhr.withCredentials = true;

        xhr.onreadystatechange = () => {
            if (xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 204)) {
                window.open(`${this.shopDomain}`, '_blank');
                this.navigateToViewCasePage();
            }
        };
        xhr.send();
    }
        navigateToViewCasePage() {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.upcatedCaseId,
                    objectApiName: 'Case',
                    actionName: 'view'
                },
            });
        }
}