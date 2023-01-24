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
    /*
    get itemtodisplay() {
        return this.itemtodisplay;
    }

    set itemtodisplay(value) {
        /*
        if(value == null || value === undefined){
            return;
        }
        console.log('JSON.stringify(value) ' +  JSON.stringify(value) );
        this.itemtodisplay = JSON.parse(JSON.stringify(value));

        if(this.currentreasoncode ===  this.itemtodisplay.value ) {
            this.buttonClass = "slds-button slds-button_neutral slds-button_brand";
        } else {
            this.buttonClass = "slds-button slds-button_neutral";
        }
    }
*/
}