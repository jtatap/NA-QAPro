import { LightningElement, track, wire, api } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import REASON_CODE_FIELD from "@salesforce/schema/Case.Reason_Code__c";
import { updateRecord } from 'lightning/uiRecordApi';
import getCase from '@salesforce/apex/NF_ReasonCodeController.getCase';
import { getRecord } from 'lightning/uiRecordApi';
import { getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Example extends LightningElement {
    @track listOfReasonCodes;
    @track editMode = false;
    @track allCaseAttributes;
    @track filteredCaseAttributes;
    @track isLoaded = false;
    @track caseRecord;
    @track currentReasonCode;
    @track mapData;
    @api recordId;
    @api isLoaded = false;

    @track Reason_Code_Details;

    @api
    get caseRecord(){
        return this.caseRecord;
    }

    handleSuccess(event){
        this.isLoaded = true;
        const theEvent = new ShowToastEvent({
            "title":"Success!",
            "message":"Case has been updated",
            "variant":"success"
        });
        this.dispatchEvent(theEvent);
        this.editMode = false;
    }

    handleSubmit(event){
        this.isLoaded = false;
    }

    handleError(event){
        const payload = event.detail;
        console.log(JSON.stringify(payload));
        this.isLoaded = true;
    }

    /* 

    Getters
    */
    
    get display_ZdPVHStoreNumber__c(){
        if(this.mapData.Reason_Code__c.value == 'Service'){
            return true;
        }
        if(this.mapData.ZdPVHStoreNumber__c.value == '' || this.mapData.ZdPVHStoreNumber__c.value == null){
            return "display: none;";
        }
        if(this.mapData.ZdPVHStoreNumber__c.value != null){
            return true;
        }
        if(this.mapData.Reason_Code_Details__c.value == 'Good Service'){
            return true;
        } 
        else {
            return "display: none;";
        }
    }
    get required_ZdPVHStoreNumber__c(){
        if(this.display_ZdPVHStoreNumber__c == true){
            return true;
        } else {
            false;
        }
    }

    get display_ZdPVHDistrictNumber__c(){
        if(this.mapData.Reason_Code__c.value == 'Service'){
            return true;
        }
        if(this.mapData.ZdPVHDistrictNumber__c.value == ''){
            return "display: none;";
        }
        if(this.mapData.ZdPVHDistrictNumber__c.value != null ){
            return true;
        }
        if(this.mapData.Reason_Code_Details__c.value == 'Good Service'){
            return true;
        } else {
            return "display: none;";
        }
    }
    get required_ZdPVHDistrictNumber__c(){
        if(this.display_ZdPVHDistrictNumber__c == true){
            return true;
        } else{
            false;
        }
    }

    get required_ZdPVHDateofServiceIssue__c(){
        if(this.isRequired1 == true){
            return true;
        } else{
            false;
        }
    }

    get isRequired1(){
        if(this.mapData.ZdPVHDateofServiceIssue__c.value != null){
            return true;
        }
        if(this.mapData.Reason_Code_Details__c.value == 'Poor Service'){
            return true;
        } else {
            return "display: none;";
        }
    }

    get isAccInfoReason(){
        if(this.mapData.Reason_Code_Details__c.value  == "Edit Account Information"){
            return true;
        }

        if(this.mapData.ZdPVHDateofServiceIssue__c.value == "Update Account Info Reason"){
            return true;
        } else {
            return "display: none;";
        }
    }

    get display_Reason_Code_Details__c(){
        if(this.mapData.Reason_Code_Details__c.value != null){return true;}
        if(this.mapData.Reason_Code__c.value == null || this.mapData.Reason_Code__c.value == '--None--' || this.mapData.Reason_Code__c.value === undefined){
            return "display: none;";
        } else {
            return true;
        }
    }

    get display_Reason_Sub_detail__c(){
        console.log('display_Reason_Sub_detail__c ');
        console.log('this.mapData.Reason_Sub_detail__c.value ' + this.mapData.Reason_Sub_detail__c.value);
        console.log('this.mapData.Reason_Code_Details__c.value ' + this.mapData.Reason_Code_Details__c.value);
        if(this.mapData.Reason_Sub_detail__c.value != null || this.mapData.Reason_Code_Details__c.value != null){
            return true;
        }
        if(this.mapData.Reason_Code_Details__c.value == null){
            return "display: none;";
        }
        if( this.mapData.Reason_Code_Details__c.value == '--None--' || this.mapData.Reason_Code_Details__c.value === undefined){
            return "display: none;";
        } else {
            return true;
        }
    }
    get display_Reason_Code_Product_Category__c(){
        if(this.mapData.Reason_Code__c.value == "Product"){
            if(((this.mapData.Reason_Code_Details__c.value === 'Care Instructions') || 
            (this.mapData.Reason_Code_Details__c.value === 'Counterfeit Merchandise') ||
            (this.mapData.Reason_Code_Details__c.value === "Defective Merchandise") ||
            (this.mapData.Reason_Code_Details__c.value === 'Product Inquiry') ||
            (this.mapData.Reason_Code_Details__c.value === 'Product Repair') ||
            (this.mapData.Reason_Code_Details__c.value === 'Sizing Feedback') ||
            (this.mapData.Reason_Code_Details__c.value === 'Sizing Question')) &&
            (this.mapData.Reason_Code_Product_Category__c.value  != '--- None ---' && this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value  != '--- None ---')
            ){   
                return true; 
            } else{
                return "display: none;";
            }
        }
        if(this.mapData.Reason_Code__c.value != "Product"){
            return "display: none;";
        }
        if(this.mapData.Reason_Code_Product_Category__c.value != null){return true;}
        if((this.mapData.Reason_Sub_detail__c.value  == "Care Instructions") || 
        (this.mapData.Reason_Sub_detail__c.value  == "Counterfeit Merchandise") ||
        (this.mapData.Reason_Sub_detail__c.value  == "Defective Merchandise") ||
        (this.mapData.Reason_Sub_detail__c.value  == "Product Inquiry") ||
        (this.mapData.Reason_Sub_detail__c.value  == "Product Repair") ||
        (this.mapData.Reason_Sub_detail__c.value  == "Sizing Feedback") ||
        (this.mapData.Reason_Sub_detail__c.value  == "Sizing Question") ){
            return true;
        }
        if(this.mapData.Reason_Sub_detail__c.value == null || this.mapData.Reason_Sub_detail__c.value == '--None--' || this.mapData.Reason_Sub_detail__c.value === undefined){
            return "display: none;";
        } 
        else{return "display: none;";}
    }
    get display_Reason_Code_Product_Sub_Categories_Widge__c(){
        if(this.mapData.Reason_Code__c.value != "Product"){
            return "display: none;";
        }
        if(this.mapData.Reason_Code_Product_Category__c.value != '--- None ---' && ( this.mapData.Reason_Code_Product_Category__c.value == 'Accessories' || 
        this.mapData.Reason_Code_Product_Category__c.value == 'Footwear' || this.mapData.Reason_Code_Product_Category__c.value == 'Home Products' 	 || 
        this.mapData.Reason_Code_Product_Category__c.value == 'Outerwear' ||  this.mapData.Reason_Code_Product_Category__c.value == 'Swimwear' ||
        this.mapData.Reason_Code_Product_Category__c.value == 'Underwear')){
            return true;
        }
        if(this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value != null){return true;}
        if(this.mapData.Reason_Code_Product_Category__c.value == null || this.mapData.Reason_Code_Product_Category__c.value == '--None--' || this.mapData.Reason_Code_Product_Category__c.value === undefined){
            return "display: none;";
        } else {
            return true;
        }
    }
    get display_Reason_Code_Manufacturers__c(){
        if(this.mapData.Reason_Code_Details__c.value == null){
            return "display: none;";
        }
        if(this.mapData.Reason_Code_Details__c.value == "Defective Merchandise"){
            return true;
        }
        if( this.mapData.Reason_Code_Manufacturers__c.value != null || this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value == null || this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value == '--None--' || this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value === undefined){
            return "display: none;";
        } else {
            return "display: none;";
        }
    }
    
    get display_Sku_Style_Number__c(){
        if(this.mapData.Sku_Style_Number__c.value != null){
            return true;
        }
        if( this.mapData.Reason_Code_Manufacturers__c.value == null || this.mapData.Reason_Code_Manufacturers__c.value == '--None--' || this.mapData.Reason_Code_Manufacturers__c.value === undefined){
            return "display: none;";
        } else {
            return true;
        }
    }

    get isProCatSubSelected(){
        if(this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value == 'Elite/LZR Competition' || 
            this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value  =='General Swimwear'){
            return true;
        } else {
            return "display: none;";
        }
    }
    handlebuttonpress(event){
        try{
            const inputFields = this.template.querySelectorAll('lightning-input-field');
            console.log('handlebuttonpress ');
            console.log('inputFields ' + inputFields);
            console.log('inputFields.size ' + inputFields.length);
            if (inputFields) {
                inputFields.forEach(field => {
                    console.log('Field ' + JSON.stringify(field) );
                    field.value=null;
                    
                    if(field.name === "ZdPVHStoreNumber__c") {
                        field.value = '';
                    }
                    
                    if(field.name === "ZdPVHDistrictNumber__c") {
                        field.value = '';
                    }
                });
            }
            this.mapData.Reason_Code_Product_Sub_Categories_Widge__c.value = '';
            this.mapData.ZdPVHStoreNumber__c.value = '';
            this.mapData.ZdPVHDistrictNumber__c.value = '';
            
            console.log('ME:handlebuttonpress handlebuttonpress Handle Button event.detail ' + event.detail);
            this.currentReasonCode = event.detail;
            this.template.querySelector(".Reason_Code__c").value = event.detail;
            console.log('MX:handlebuttonpress handlebuttonpress Handle Button event.detail ' + event.detail);
        } catch( error ) {
            console.error(error);
        }
    }
    handleInputChange(event){
        try{
            console.log('event.target.value ' + event.target.value);
            console.log('event.target.fieldName ' + event.target.fieldName);
            if(event.target.value != null){
                console.log();
                this.mapData[event.target.fieldName].value = event.target.value;
            }
        } catch( error ) {
            console.error(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: "0121U000000SgktQAC", fieldApiName: REASON_CODE_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log("Data :  " + data.values);
            console.log(JSON.stringify(data.values));
            this.listOfReasonCodes = data.values;

            for (let i = 0; i < this.listOfReasonCodes.length; i++) {
                console.log("Test " + this.listOfReasonCodes[i]);
            }
        } else if (error) {

        }
    }
    @wire(getCase, { recordId: '$recordId' })
    wiredGetCase({ error, data }) {
        console.log(JSON.stringify(data));
        this.caseRecord = data;
    }
    reasonCodeSelectionHandler(event) {
        console.info(event.target.value);
        this.template.querySelector(".Reason_Code__c").value = event.target.value;
        console.log("Calling the other class");
        this.removeClassFromClasses(".reasonCodeButton", ".slds-button_brand");
        event.target.classList.add("slds-button_brand");
    }
    handleEditClick(event) {
        try{
            this.editMode = true;
        } catch (error){
            console.error(error);
        }
    }
    removeClassFromClasses(classNameFind, ClassToRemove) {
        console.log("removeClassFromClasses ");
        console.log(classNameFind);
        console.log(ClassToRemove);

        for (let i = 0; i < this.listOfReasonCodes.length; i++) {
            this.template
                .querySelector('[data-id="' + this.listOfReasonCodes[i].value + '"]')
                .classList.remove("slds-button_brand");
            console.log("Test " + this.template.querySelector('[data-id="' + this.listOfReasonCodes[i].value + '"]'));
        }
    }

    /*View Methods */

    @api indFields = 'Reason_Code__c;Reason_Code_Details__c;Reason_Sub_detail__c;Reason_Code_Product_Category__c;Reason_Code_Product_Sub_Categories_Widge__c;Reason_Code_Manufacturers__c;Sku_Style_Number__c;ZdPVHStoreNumber__c;ZdPVHDistrictNumber__c;Third_Party_Vendors__c;ZdPVHDateofServiceIssue__c;ZdPVHUpdateAccountInfoReason__c';
    @api objectApiName = 'Case';
    record = '';
    error = '';
    fieldsFormatted = ['Id'];

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsFormatted' })
    wiredRecord({data, error}) {
        if (data) {
            this.record = data;
            this.mapData = JSON.parse(JSON.stringify(data.fields));
            this.fValues = [];
            Object.keys(data.fields).forEach((field) => {
                console.log('field '+field);
                let currentField = {value:"", apiName:""};
                currentField.value = data.fields[field].value ;
                currentField.apiName = field;
                if(currentField.apiName == 'Reason_Code__c'){
                    console.log('currentField.value ' + currentField.value);
                    this.currentReasonCode = currentField.value;
                    console.log('this.currentReasonCode ' + this.currentReasonCode);
                }
                this.fValues.push(currentField);
            });
        } else if (error) {
            this.error = error;
        }
    }
    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.editMode = false;
        this.isLoaded = true;
    }
    connectedCallback() {
        this.fieldsFormatted = (this.indFields || 'Id').split(';').map(field => this.objectApiName+'.'+field);
        this.isLoaded = true;
    }
}