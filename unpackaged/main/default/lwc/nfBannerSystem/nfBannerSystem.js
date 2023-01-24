import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MESSAGE from "@salesforce/schema/NF_Banner__c.Message__c";
import ACTIVE from "@salesforce/schema/NF_Banner__c.Active__c";
import BACKGROUNDCOLOR from "@salesforce/schema/NF_Banner__c.BackgroundColor__c";

export default class NfBannerSystem extends LightningElement {
    //NF_BannerSystemController
    // --backgroundColor: ;
    //--textColor: #FFFFFF;

    @api bannerId;

    brandName;
    backgroundColor;
    textColor;

    @wire(getRecord, { recordId: "$bannerId", fields: [MESSAGE, BACKGROUNDCOLOR], optionalFields: [ACTIVE] })
    banner;

    get messsage() {
        return getFieldValue(this.banner.data, MESSAGE);
    }
    /*
    get backgroundColor(){
        bkColor = getFieldValue(this.banner.data, backgroundColor);
        console.log(' bkColor ' + bkColor);
        document.documentElement.style.setProperty( "--sds-c-alert-text-color", bkColor );
        return bkColor;
    }
    */

    renderedCallback() {
        console.log("NF_Banner_System | bannerId " + this.bannerId);
        console.log("NF_Banner_System | Render Callback " + getFieldValue(this.banner.data, BACKGROUNDCOLOR));
        console.log("NF_Banner_System | Render Callback " + getFieldValue(this.banner.data, MESSAGE));
        console.log(getFieldValue(this.banner.data, BACKGROUNDCOLOR));
        let bkColor = getFieldValue(this.banner.data, BACKGROUNDCOLOR);
        console.log(bkColor);
        //document.documentElement.style.setProperty("--sds-c-alert-color-background", bkColor);
        //this.getElementsByClassName(".backgroundColor").style.backgroundColor = bkColor;

        let backgroundDiv = this.template.querySelector(".backgroundColor");
        backgroundDiv.style.backgroundColor = bkColor;

        //backgroundColor
        //console.log('this.error' + this.error);
    }

    /*
    connectedCallback() {
        debugger;
        bkColor = getFieldValue(this.banner.data, backgroundColor);
        console.log(' bkColor ' + bkColor);
        document.documentElement.style.setProperty( "--sds-c-alert-text-color", bkColor );
        
    } */
    /*console.log('Luis was here');
    document.documentElement.style.setProperty( "--sds-c-alert-color-background", "white" );
    document.documentElement.style.setProperty( "--sds-c-alert-text-color", "black" );
    console.log("End of luis"); 
    //document.documentElement.style.setProperty('--titleColor', 'red');
    
    debugger;
    
    getPreviewMessage({recordId : this.recordId})
    .then(result => {
        if(result){
            console.log(JSON.stringify(result) );
        }
    })
    .catch(error => {  
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error Retrieving records',
                message: 'Error Retrieving records',
                variant: 'Error Retrieving records'
            })
            );
        })
    }
    
    */
}