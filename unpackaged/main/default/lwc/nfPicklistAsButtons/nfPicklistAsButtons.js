import { api,LightningElement, track } from 'lwc';

export default class NfPicklistAsButtons extends LightningElement {
   
    @api currentreasoncode;
    @api itemtodisplay;


    handleButtonClick(){
        const selectEvent = new CustomEvent('buttonselected', {
            detail: this.itemtodisplay.value
        });
        this.dispatchEvent(selectEvent);
    }

    get buttonClass(){
        if(this.currentreasoncode == this.itemtodisplay.value){
            return 'reasonCodeButton slds-button slds-button_neutral slds-button_brand';
        } else {
            return 'reasonCodeButton slds-button slds-button_neutral';
        }
    }
    
}