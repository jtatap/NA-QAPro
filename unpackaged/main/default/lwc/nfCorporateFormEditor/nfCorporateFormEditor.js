import { LightningElement, api,track, wire} from 'lwc';
import retrieveFields from '@salesforce/apex/NfCorporateRequestFormController.retrieveFieldsApiAndLabel';  

import ID_FIELD from '@salesforce/schema/Corporate_Form_Configuration__c.Id';
import FIELDDATA from '@salesforce/schema/Corporate_Form_Configuration__c.FieldData__c';
import { updateRecord,getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CsvStatementLabel from '@salesforce/label/c.CsvStatementLabel';

const fields = [ID_FIELD, FIELDDATA];
export default class NfCorporateFormEditor extends LightningElement {
    @api csv;
    @api recordId;
    @api areDetailsVisible = false;
    allOptions = [];
    allOptionsMap = new Map();
    configurationRecord;
    options = [];
    requiredOptions = [];
    selectedOptionsToSave = [];
    values = [];
    valuesAlreadyAdded = [];
    label = {
        CsvStatementLabel
    };

    @wire(getRecord, { recordId: "$recordId", fields }) wireRecords ({ error, data }) {
        if (data) {
            this.configurationRecord = data;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {    
        console.log('areDetailsVisible' + this.areDetailsVisible);
        retrieveFields({}).then(result => {
            for (let i = 0; i < result.length; i++) {
                let option = { label: result[i].label, value: result[i].name.toLowerCase()};
                this.allOptions = [ ...this.allOptions, option ];
                this.options = [ ...this.options, option ];
                this.allOptionsMap.set( option.value , option.label);
            }

            this.allOptionsMap.delete();

            this.allOptionsMap.delete('supplied_first_name__c');
            this.allOptionsMap.delete('supplied_last_name__c');
            this.allOptionsMap.delete('suppliedemail');
            this.allOptionsMap.delete('description');
            this.allOptionsMap.delete('brand__c');
            this.allOptionsMap.delete('business_group__c');
            
            for (let i = 0; i < this.values.length; i++) {
                let selectedOption = {name:"", label:"", required:false};
                selectedOption.name = this.values[i];
                selectedOption.label = this.allOptionsMap.get(this.values[i]);
                selectedOption.required = false;
                this.selectedOptionsToSave.push(selectedOption);
            }
            this.valuesAlreadyAdded = this.csvToJson(this.configurationRecord.fields.FieldData__c.value);        
            console.log(' this.valuesAlreadyAdded  ' + this.valuesAlreadyAdded);    
            for (let i = 0; i < this.valuesAlreadyAdded.length; i++) {
                console.info(' this.valuesAlreadyAdded[i].fieldName   '+this.valuesAlreadyAdded[i].fieldName);
                console.log('|'+this.valuesAlreadyAdded[i].fieldName+'|');
                console.log('|'+this.valuesAlreadyAdded[i].fieldName.trim()+'|');
                this.values.push(this.valuesAlreadyAdded[i].fieldName.replace(/\s/g,''));
                
                let selectedOption = {
                    name: 'name',
                    label: 'label',
                    required: false
                };
                selectedOption.name = this.valuesAlreadyAdded[i].fieldName;
                selectedOption.label = this.valuesAlreadyAdded[i].labelToDisplay;
                selectedOption.required = (this.valuesAlreadyAdded[i].required === 'true');
                this.selectedOptionsToSave.push(selectedOption);
            }            
            let unique = [...new Set( this.values)];
            this.values = [...unique];
        })
        .catch(error => {
            console.log(error);
        });
    }

    filter(event) {
        let filter = event? 
        new RegExp(this.template.querySelector('lightning-input').value, 'ig'):
        { test: function() { return true }}
        const allOptions = new Set(this.values)
        this.options = this.allOptions.filter(option => (filter.test(option.value) || allOptions.has(option.value)))
    }
    handleChange(event) {
        this.values = [...event.target.value]
        this.filter(true)
    }
    updateSelectedValues(e){
        let unique = [...new Set( this.values)];
        this.values = [...unique];

        this.values = [...e.target.value];
        console.log( this.values);
        this.selectedOptionsToSave = [];
        for (let i = 0; i < this.values.length; i++) {
            let selectedOption = {
                name: 'name',
                label: 'label',
                required: false
            };
            selectedOption.name = this.values[i];
            selectedOption.label = this.allOptionsMap.get(this.values[i]);
            selectedOption.required = false;
            this.selectedOptionsToSave.push(selectedOption);
        }
        console.log('Values :  ' + this.values );
        this.generateCsv();
    }

    generateCsv(){
        let csvText= 'fieldName,required,labelToDisplay' + '\n';
        for (let i = 0; i < this.selectedOptionsToSave.length; i++) {
            let newLine = this.selectedOptionsToSave[i].name.trim()+','+this.selectedOptionsToSave[i].required+','+this.selectedOptionsToSave[i].label+'\n';
            csvText = csvText + newLine;
        }
        console.log('csvText \n'+csvText);
        this.csv = '';
        this.csv = csvText;
    }

    updateCSV() {   
        try{
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[FIELDDATA.fieldApiName] = this.csv;;
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Success', message: 'Record updated', variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.log("error " + error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        } catch (error){
            console.error(error);
        }
    }

    csvToJson(recordToProcess){
        console.log(' recordToProcess \n ' + JSON.stringify(recordToProcess) );
        var lines = recordToProcess.split("\n");
        var csvResults = [];
        var fieldsAlreadyInConfig = [];
        var headers;
        headers = lines[0].split(",");
    
        for (var i = 1; i < lines.length; i++) {
            var obj = {};
            if(lines[i] == undefined || lines[i].trim() == "") {
                continue;
            }
            var words = lines[i].split(",");
            for(var j = 0; j < words.length; j++) {
                obj[headers[j].trim()] = words[j];
            }
            csvResults.push(obj);
        }

        console.log(csvResults);

        for (let i = 0; i < csvResults.length; i++) {
            console.log(csvResults[i].fieldName);
            console.log(csvResults[i].required);
            console.log(csvResults[i].labelToDisplay);

            fieldsAlreadyInConfig.push(csvResults[i]);
        }
        return fieldsAlreadyInConfig;
    }

    updateFreeFormColum(event){
        console.log('updateFreeFormColum');
        console.log(event.target.name);

        var foundElement = this.selectedOptionsToSave.find(function(element){
            return element.name === event.target.name;
        });        
        console.log('foundElement ' + JSON.stringify(foundElement));
        foundElement.label = event.target.value;
        this.generateCsv();
    }
    updateRequired(event){
        console.log('updateFreeFormColum');
        console.log(event.target.name);

        var foundElement = this.selectedOptionsToSave.find(function(element){
            return element.name === event.target.name;
        });        
        console.log('foundElement ' + JSON.stringify(foundElement));
        if(foundElement.required == true){
            foundElement.required = false;
        } else {
            foundElement.required = true;
        }
        this.generateCsv();
    }
}