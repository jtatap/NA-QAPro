import { LightningElement, api } from 'lwc';
import getFooterData from '@salesforce/apex/pvhCommunityFooterController.getFooterData';
import getFooterCopyrightAreaData from '@salesforce/apex/pvhCommunityFooterController.getFooterCopyrightAreaData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CalvinCommunityFooter extends LightningElement {
    mapHeaderToItems = [];
    mapCopyrightItemsToValue = [];
    renderFooter;
    error;
    @api brandName;
    @api iscovidinfovisible;
    covidURL = 'https://www.calvinklein.us/en/covid-19-information';

    connectedCallback() {
        getFooterData({brandName : this.brandName})
        .then(result => {
        if(result){
            for (let [key, value] of Object.entries(result)) {
                let currentData = [];
                for (let [k, v] of Object.entries(value)) {
                    let rowData = {};
                    for (let [fLabel, fValue] of Object.entries(v)) {
                        if(fLabel == 'Name__c') { 
                            if(fValue == 'Call Us:') {
                                rowData['isNotURL'] = true;
                            }
                            rowData['Label'] = fValue; 
                        }
                        if(fLabel == 'Value__c') { rowData['Value'] = fValue; }
                        if(fLabel == 'Open_In_New_Tab__c') { rowData['NewTab'] = fValue; }
                    }
                    currentData.push(rowData);
                }
                this.mapHeaderToItems.push({value:currentData, key:key});
               
            }
            getFooterCopyrightAreaData({brandName : this.brandName})
            .then(result => {
                if(result){
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
                        console.log('-- data checking--',this.mapCopyrightItemsToValue);
                        this.mapCopyrightItemsToValue.push({value:currentData, key:key});
                        
                    }
                    if(this.brandName == 'Calvin Klein - CA') { this.covidURL = 'https://www.calvinklein.ca/en/covid-19-information'; }
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

    dropdownClicked(e) {
        for(var i=0; i < this.template.querySelectorAll('.footer .footer-links .footer-links-col').length; i++) {
            if(i == e.target.dataset.index) {
                if(e.target.dataset.expand === "true") {
                    this.template.querySelectorAll('.footer .footer-links .footer-links-col')[i].classList.remove('openHeaderDropdown');
                    this.template.querySelectorAll('.footer .footer-links .footer-links-col')[i].classList.add('expand');
                    this.template.querySelectorAll('.iconClass')[i].classList.remove('upArrow');
                    e.target.dataset.expand = "false";
                } else if(e.target.dataset.expand === "false") {
                    this.template.querySelectorAll('.footer .footer-links .footer-links-col')[i].classList.add('openHeaderDropdown');
                    this.template.querySelectorAll('.footer .footer-links .footer-links-col')[i].classList.remove('expand');
                    this.template.querySelectorAll('.iconClass')[i].classList.add('upArrow');
                    e.target.dataset.expand = "true";
                }
            }
            else {
                this.template.querySelectorAll('.footer .footer-links .footer-links-col')[i].classList.add('expand');
                this.template.querySelectorAll('.iconClass')[i].classList.remove('upArrow');
            }
        }
    }
}