/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'10, 2020
*/

import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LOG_OBJECT from '@salesforce/schema/Log__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEVEL_FIELD from '@salesforce/schema/Log__c.Level__c';
import EXCEPTION_TYPE_FIELD from '@salesforce/schema/Log__c.Type__c';

export default class LogViewComponent extends LightningElement {

    selectedFromDate = new Date().toISOString();
    selectedToDate = this.selectedFromDate;
    value ='FATAL';
    classname;
    showRange = false;
    inputValuesMap = {}; 
    isException = true;
    exceptionTypePicklistValues;
    
    @wire(getObjectInfo, { 
        objectApiName: LOG_OBJECT 
    }) objectInfo;

    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName: LEVEL_FIELD
    }) loglevels;
    
    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName: EXCEPTION_TYPE_FIELD
    })
    getExceptionPicklistValues(result) {
        if (result.data) {
            this.exceptionTypePicklistValues = [{label: 'All', value: '', selected: true}, ...result.data.values];
        } else if (result.error) {
           console.log('Error fetching picklist values: '+JSON.stringify(result.error));
        }
    }
    connectedCallback(){
        this.inputValuesMap['loglevel'] = this.value;
        this.inputValuesMap['fromlogdate'] = this.selectedFromDate;
        this.inputValuesMap['tologdate'] = null;
        this.inputValuesMap['classname'] = null;
        this.inputValuesMap['type'] = null;
    }

    keycheck(event){
        if (event.which == 13){
            this.handleChange(event);
        }
    }

    handleChange(event) {
        if(event.target.name){
            this.inputValuesMap[event.target.name] = event.target.value;
        }
        if(event.target.name == 'loglevel'){
            if(event.target.value != 'FATAL'){
                this.isException = false;
                this.inputValuesMap['classname'] = null;
                this.inputValuesMap['type'] = null;
            } else {
                this.isException = true;
            }
        }
        this.template.querySelector('c-datatable-component').handleLoad(this.inputValuesMap);
    }

    handleToggle(event){
        let logDate = this.template.querySelector("[data-id='fromlogdate']")
        if(event.target.checked){
            this.showRange = true;
            logDate.label = 'From';
            this.inputValuesMap['tologdate'] = this.inputValuesMap['fromlogdate'];
            this.selectedToDate = this.inputValuesMap['fromlogdate'];
        } else {
            this.showRange = false;
            logDate.label = 'Log Date';
            this.inputValuesMap['tologdate'] = null;
            this.template.querySelector('c-datatable-component').handleLoad(this.inputValuesMap);
        }
    }
}