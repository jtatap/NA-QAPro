import { LightningElement} from 'lwc';
import getFooterData from '@salesforce/apex/pvhCommunityFooterController.getFooterData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TommyHLabel from '@salesforce/label/c.TommyHLabel';
import STORE_LOCATOR from '@salesforce/label/c.STORE_LOCATOR';
import Follow_Us from '@salesforce/label/c.Follow_Us';
import Tommy_Logo from '@salesforce/contentAssetUrl/TommyLogoWhite';


export default class TommyCommunityFooter extends LightningElement {
    mapHeaderToItems = [];
    policieValues = [];
    renderFooter;
    error;
    tommyLogo = Tommy_Logo;
    label = {
        TommyHLabel,
        STORE_LOCATOR,
        Follow_Us
    };

    connectedCallback() {
        getFooterData({brandName : 'Tommy Hilfiger'})
        .then(result => {
        if(result){
            console.log('result',result);
            for (let [key, value] of Object.entries(result)) {
                let currentData = [];
                for (let [k, v] of Object.entries(value)) {
                    let rowData = {};
                    for (let [fLabel, fValue] of Object.entries(v)) {
                        if(fLabel == 'Name__c') { rowData['Label'] = fValue; }
                        if(fLabel == 'Value__c') { rowData['Value'] = fValue; }
                        if(fLabel == 'Open_In_New_Tab__c') { rowData['NewTab'] = fValue; }
                    }
                    currentData.push(rowData);
                }
                if(key != "POLICIES"){
                    this.mapHeaderToItems.push({value:currentData, key:key});
                }else{
                    this.policieValues.push({value:currentData, key:key});
                }
                
                console.log('this.policieValues',this.policieValues);
            }
            for(let i=0;i<this.policieValues.length;i++){
                for(let j=0;j<this.policieValues[i].value.length;j++){
                    this.policieValues[i].value[j].bshowPipline = j == this.policieValues[i].value.length -1 ? false : true;
                }
            }
            this.renderFooter = true;
        }
        })
        .catch(error => {  
            this.dispatchEvent(
                new ShowToastEvent({
                title: 'Missing Footer Item',
                message: 'Something Went Wrong!',
                variant: 'error'
                })
            );
        })
    }

    followusClicked(e) {
        if(e.target.dataset.expand === "false") {
            this.template.querySelector('.footerMiddleCM').classList.add('showSocialMediaPanel');
            this.template.querySelector('.footerMiddleCM').classList.remove('hideSocialMediaPanel');
            e.target.dataset.expand = "true";
        }
        else if(e.target.dataset.expand === "true") {
            this.template.querySelector('.footerMiddleCM').classList.add('hideSocialMediaPanel');
            this.template.querySelector('.footerMiddleCM').classList.remove('showSocialMediaPanel');
            e.target.dataset.expand = "false";
        }
    }

    dropdownClicked(e) {
        for(var i=0; i < this.template.querySelectorAll('.footer-accordion-section-content').length; i++) {
            if(i == e.target.dataset.index) {
                if(e.target.dataset.expand === "true") {
                    this.template.querySelectorAll('.footer-accordion-section-content')[i].classList.remove('showdropdown');
                    this.template.querySelectorAll('.footer-accordion-section-content')[i].classList.add('hidedropdown');
                    e.target.dataset.expand = "false";

                    this.template.querySelectorAll('.th-m-footer-arrow-left')[i].classList.remove('downArrow');
                    this.template.querySelectorAll('.th-m-footer-arrow-left')[i].classList.add('upArrow');
                } else if(e.target.dataset.expand === "false") {
                    this.template.querySelectorAll('.footer-accordion-section-content')[i].classList.add('showdropdown');
                    this.template.querySelectorAll('.footer-accordion-section-content')[i].classList.remove('hidedropdown');
                    e.target.dataset.expand = "true";

                    this.template.querySelectorAll('.th-m-footer-arrow-left')[i].classList.add('downArrow');
                    this.template.querySelectorAll('.th-m-footer-arrow-left')[i].classList.remove('upArrow');
                }
            }
        }
    }
}