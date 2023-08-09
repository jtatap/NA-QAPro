import {api, LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import retrieveFormConfiguration from '@salesforce/apex/NfCorporateRequestFormController.retrieveFormConfiguration';  
import saveFiles from '@salesforce/apex/NfCorporateRequestFormController.saveFiles';  
import createCase from "@salesforce/apex/NfCorporateRequestFormController.createCase";
import retreiveRecordType from "@salesforce/apex/NfCorporateRequestFormController.retreiveRecordType";
const MAX_FILE_SIZE = 1000000000; //100mb

export default class NfCorporateRequestForm extends LightningElement {
	@api attachmentsInstructions;
	@api brandLabel;
	@api businessGroupLabel;
	@api descriptionLabel;
	@api emailLabel;
	@api firstNameLabel;
	@api instructions;
	@api lastNameLabel;
	@api recordTypeName;
	@api maxFilesInsertedLabel;
	@api maxFilesInsertedSubinstructions;
	@api thankyouMessage;
	@track caseCreatedSuccessfully = false;
	@track data;
	@track fieldsToShow = [];
	@track fileNames = '';
	@track filesUploaded = [];
	@track isLoading = true;
	@track recordTypeId;
	@track resultFromcsvToJson;
	caseNumber;
	content;
	file;
	fileContents;
	fileName;
	fileReader;
	mapBusinessGroup = new Map();
	uploadedFiles = [];

	@api
	get maxFilesUploaded(){
		if(this.filesUploaded.length < 5){
			return false;
		} else {
			return true;
		}
	} 
	connectedCallback() {
		retrieveFormConfiguration({})
		.then((result) => {
			for (var i = 1; i < result.length; i++) {
				this.mapBusinessGroup.set(
					result[i].BusinessGroup__c,
					result[i].FieldData__c
					);
				}
		}).catch((error) => {
				console.error(error);
		});
		retreiveRecordType({recordTypeName: this.recordTypeName })
		.then((result) => {
			this.recordTypeId = result;
		}).catch((error) => {
			console.error(error);
		});
	}
	handleFileChanges(event) {
		try{ 
			let files = event.target.files;			
			if (files.length > 0 && files.length <=5) {
				if((files.length + this.filesUploaded.length) <= 5){
					let filesName = '';
					for (let i = 0; i < files.length; i++) {
						let file = files[i];
						filesName = filesName + file.name + ',';
						let freader = new FileReader();
						freader.onload = f => {
							let base64 = 'base64,';
							let content = freader.result.indexOf(base64) + base64.length;
							let fileContents = freader.result.substring(content);
							this.filesUploaded.push({
								Title: file.name,
								VersionData: fileContents
							});
						};
						freader.readAsDataURL(file);
					}
					this.fileNames = filesName.slice(0, -1);
				} else {
					console.log('files.length  ' + files.length );
					console.log('filesUploaded.length  ' + this.filesUploaded.length );
					const evt = new ShowToastEvent({ title: this.maxFilesInsertedLabel, message: this.maxFilesInsertedSubinstructions, variant: 'warning', mode: 'dismissable' });
					this.dispatchEvent(evt);
				}
			} else {
				const evt = new ShowToastEvent({ title: this.maxFilesInsertedLabel, message: this.maxFilesInsertedSubinstructions, variant: 'warning', mode: 'dismissable' });
				this.dispatchEvent(evt);
			}
		} catch (error){ 
			console.error(error);
		}
	}
	handleSaveFiles(caseId) {
		this.showLoadingSpinner = true;
		saveFiles({filesToInsert: this.filesUploaded, caseId: caseId})
		.then(data => {
			this.showLoadingSpinner = false;
		})
		.catch(error => {console.error(error);});
	}
	removeFile(event) {
        var index = event.currentTarget.dataset.id;
        this.filesUploaded.splice(index, 1);
    }
	testMethod(event) {
		this.isLoading = true; //This shows the spinner
		createCase({ caseData: JSON.stringify(event.detail.fields) , recordTypeName: this.recordTypeName })
			.then((result) => {
				this.caseCreatedSuccessfully = true;
				this.isLoading = false;
				this.caseNumber = result.CASENUMBER;
				this.handleSaveFiles(result.CASEID);
				this.thankyouMessage = result.THANKYOUMESSAGE;
			})
			.catch((error) => {
				this.isLoading = false;
			});
  	}
	showSpinner() {
		this.isLoading = false;
	}
	csvToJSON(csv) {
		var lines = csv.split("\n");
		var result = [];
		var headers;
		headers = lines[0].split(",");
		for (var i = 1; i < lines.length; i++) {
			var obj = {};
			if (lines[i] == undefined || lines[i].trim() == "") {
				continue;
			}
			var words = lines[i].split(",");
			for (var j = 0; j < words.length; j++) {
				obj[headers[j].trim()] = words[j];
			}
			result.push(obj);
		}
	}
	businessGroupUpdated(event) {
		this.fieldsToShow = [];
		var lines = this.mapBusinessGroup.get(event.detail.value).split("\n");
		var csvResults = [];
		var headers;
		headers = lines[0].split(",");
		for (var i = 1; i < lines.length; i++) {
			var obj = {};
			if (lines[i] == undefined || lines[i].trim() == "") {
				continue;
			}
			var words = lines[i].split(",");
			for (var j = 0; j < words.length; j++) {
				obj[headers[j].trim()] = words[j];
			}
			csvResults.push(obj);
		}
		for (let i = 0; i < csvResults.length; i++) {
			csvResults[i].required = (csvResults[i].required === "true");
			this.fieldsToShow.push(csvResults[i]);
		}
	}
	showToast(title,msg) {
        const event = new ShowToastEvent({title: title,msg:msg,variant:'success',});
        this.dispatchEvent(event);
    }
}