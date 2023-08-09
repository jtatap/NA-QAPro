import { api, LightningElement, track } from 'lwc';

import getFormConfig from '@salesforce/apex/NF_BrandFormController.getFormConfig';
import createCase from '@salesforce/apex/NF_BrandFormController.createCase';
import updateFileDescription from '@salesforce/apex/NF_BrandFormController.updateFileDescription';

import FILE_UPLOAD_LABEL from '@salesforce/label/c.Message_UploadFiles';
import BRAND_HEADER_ALERT from '@salesforce/label/c.Brand_Form_Alert';
import BRAND_FORM_RESOURCE from '@salesforce/resourceUrl/BrandFormResources';

import { loadStyle } from 'lightning/platformResourceLoader';

const PICKLIST_DEPENDENCY = {
	"Reason_Code__c": ["Reason_Code_Details__c"],
	"Channel__c": ["Reason_Code__c", "Reason_Code_Details__c"]
}

const VISIBILITY_DEPENDENCY = {
	"Reason_Code__c": "Reason_Code_Details__c"
}

const FIELD_VALIDATION = {
	"Supplied_First_Name__c": {
		pattern: "^[a-zA-Z]+([-' ][a-zA-Z]+)*$",
		messageWhenPatternMismatch: "Please Provide Valid First Name",
		messageWhenTooShort: "First Name must be minimum 2 characters",
		minLength: 2
	},
	"Supplied_Last_Name__c": {
		pattern: "^[a-zA-Z]+([-' ][a-zA-Z]+)*$",
		messageWhenPatternMismatch: "Please Provide Valid Last Name",
		messageWhenTooShort: "Last Name must be minimum 2 characters",
		minLength: 2
	},
	"SuppliedPhone": {
		pattern: "^\+?(?:[0-9\-] ?){6,15}[0-9]$",
		messageWhenPatternMismatch: "You have entered invalid phone number"
	},
	//Use below to apply validation
	
}

//Channel picklist labels for which "Additional Details" are to be shown
const AD_SHOW_CHANNEL_LABELS = ['Tommy.com', 'calvinklein.com','calvinklein.ca'];

const LOG_DATA = false;

export default class CommunityBrandForm extends LightningElement {
	@api brandname;
	@track formConfig = {}
	@track fields = [];
	@track filesToAttach = [];
	@track picklistOptions = {};
	@track supportCase = {}
	formReadyToDisplay = false;
	caseGenerated = false;
	spinner = true;
	initialLoad = false;

	brandHeader = '';

	@api smallMargin;
	@api mediumMargin;
	@api largeMargin;
	singleBrandChannelValue = '';
	selectedChannelType = '';

	connectedCallback() {
		//Load styles dynamically
		Promise.all([
			loadStyle(this, BRAND_FORM_RESOURCE + '/css/' + (this.brandname.replaceAll(' ','_')) + '.css'),
		]).then(res => {
			//
		}).catch(err => {
			this.writeLog(err);
		})

		this.writeLog('Loaded at: ' + new Date());
		getFormConfig({
			brandname: this.brandname
		}).then(res => {
			this.writeLog('Received at: ' + new Date());
			this.handleFormConfig(res);
			this.writeLog(res);
			this.formReadyToDisplay = true;
			this.spinner = false;
		}).catch(err => {
			this.writeLog(err);
		});

		// Add attribute for saving new files and deleting previous files
		this.supportCase.filesToRelate = [];
		this.supportCase.filesToDelete = [];

	}

	renderedCallback() {
		try {
			if (!this.initialLoad && this.formConfig && JSON.stringify(this.formConfig) != "{}") {
				this.initialLoad = true;

				var bodyStyles = document.body.style;

				if(this.smallMargin){
					bodyStyles.setProperty('--smallMargin', this.smallMargin);
				}
				if(this.mediumMargin){
					bodyStyles.setProperty('--mediumMargin', this.mediumMargin);
				}
				if(this.largeMargin){
					bodyStyles.setProperty('--largeMargin', this.largeMargin);
				}

				//Mimic picklist change to hide "Additional Details" field on UI
				const plistChangeEvt = new CustomEvent('optionchange', {
					detail: {
						parent: "Channel__c",
						label: "",
						value: "",
						secondaryAction: "",
						type: this.selectedChannelType || "none"
					}
				});
				this.handlePicklistChange(plistChangeEvt);
			}
		}
		catch (ex) {
			this.writeLog(ex)
		}
	}

	handleFormConfig(res) {
		if (res) {
			this.formConfig = res;
			this.singleBrandChannelValue = this.formConfig.brand.singleBrandChannelValue || '';
			if(this.singleBrandChannelValue){
				this.selectedChannelType = 'Single';
			}

			//Set Fields
			let FIELDS = [];
			var key = 0;
			res.fields.forEach(f => {
				if (f.fieldType === 'PICKLIST') {
					f.fieldOptions = res.fieldOptions[f.fieldName];

					//Sort the data at granular level
					f.fieldOptions.sort((x, y) => { return x.order - y.order });
				}

				FIELDS.push(this.addFieldValidation(f));
				var fieldsLength = FIELDS.length;
				FIELDS[fieldsLength - 1].key = ++key;
				this.writeLog(JSON.stringify(this.addFieldValidation(f)));
			});

			FIELDS.sort((x, y) => { return x.order - y.order });
			this.fields = FIELDS;
			console.log(this.fields);

			//Set brand logo
			this.brandHeader = {
				image: BRAND_FORM_RESOURCE + this.formConfig.brand.logoUrl,
				title: this.brandname,
				show: this.formConfig.brand.showLogo
			}
		}
	}

	addFieldValidation(inp) {
		let fldVal = FIELD_VALIDATION[inp.fieldName];
		if (fldVal) {
			Object.assign(inp, fldVal);
		}
		return inp;
	}

	get headerAlert() {
		return BRAND_HEADER_ALERT.replace('BRAND_ORDER_TRACK_LINK', this.formConfig.brand.orderTrackerLink);
	}

	get Fields() {
		return this.fields;
	}

	get FieldOptions() {
		let r = {};
		if (this.formConfig) {
			r = this.formConfig.fieldOptions;
		}
		return r;
	}

	get caseSuccessMessage() {
		return this.formConfig.brand.caseSuccessMessage.replace('CASENUMBER', this.supportCase.CaseNumber);
	}

	get fileUploadLabel() {
		return FILE_UPLOAD_LABEL;
	}

	handlePicklistChange(e) {
		//Clear previously additional fields
		this.fields = this.fields.filter(p => !p.additional);

		//Don't display Message section if Secondary action is 'Block' for AD change
		let fieldContainerDivs = this.getElementsBySelector('.field-container');
		let descriptionIndex = this.fields.findIndex(f => f.fieldName === 'Description');
		let allInputs = this.allInputs();
		var hideDescription = false;

		if(e.detail.parent === 'Reason_Code_Details__c' && e.detail.secondaryAction === 'Block'){
			hideDescription = true;
		}

		if(
			fieldContainerDivs && descriptionIndex > -1 &&
			fieldContainerDivs.length >= descriptionIndex &&
			allInputs.length >= descriptionIndex &&
			fieldContainerDivs[descriptionIndex] &&
			allInputs[descriptionIndex] &&
			allInputs[descriptionIndex].field.fieldName === 'Description'
		){
			if(hideDescription){
				fieldContainerDivs[descriptionIndex].classList.add('slds-hide', 'hidden-by-Secondary_Action');
			}
			else{
				fieldContainerDivs[descriptionIndex].classList.remove('slds-hide', 'hidden-by-Secondary_Action');
			}
			allInputs[descriptionIndex].hidden = hideDescription;
			allInputs[descriptionIndex].input.value = '';
		}

		//Added by Chayan Batabyal on 08/03 to hide the
		//message(description), attachment section & submit button conditionally.
		//It should be hidden if secondaryAction value in the CMDT is Block
		let bottomSection = this.template.querySelector('.bottomSection');
		if(bottomSection){
			bottomSection.style.display = e.detail.secondaryAction == 'Block' ? 'none' : 'block';
		}

		if (e.detail.parent) {
			if(e.detail.parent === 'Channel__c'){
				this.selectedChannelType = e.detail.type;
			}
			//Update DEPENDENT PICKLIST values
			this.handlePicklistPopulation(e);
		}
	}

	handlePicklistPopulation(e) {
		if (e.detail.parent) {
			let destination, destinationIndex = -1, hiddenIndex = -1;

			//Find nf-form-input instance with fieldName as "Reason_Code_Details__c"
			this.allInputs().forEach((i, p) => {
				if (
					PICKLIST_DEPENDENCY.hasOwnProperty(e.detail.parent) &&
					PICKLIST_DEPENDENCY[e.detail.parent].findIndex(f => f === i.field.fieldName) >= 0
				) {
					destination = i;
					destinationIndex = p;
				}
				else{
					destination = undefined;
					destinationIndex = -1;
				}
				this.writeLog('\nDestination index set ' + destinationIndex);

				if (i.field.fieldName === VISIBILITY_DEPENDENCY[e.detail.parent]) {
					hiddenIndex = p;
				}
				else{
					hiddenIndex = -1;
				}

				this.writeLog('Hidden index set ' + hiddenIndex + '\n');

				if (destination) {
					let selectedChannelType = this.selectedChannelType;
					destination.displayOptions = [];
					let x = [];
					destination.field.fieldOptions.forEach(op => {
						let eachOption = JSON.parse(JSON.stringify(op));
						if(selectedChannelType && (e.detail.parent === 'Channel__c' || e.detail.parent === 'Reason_Code__c')){
							let fieldToCheck = 'no' + selectedChannelType.replaceAll(' ', '');
							if(
								eachOption.value === ""
								||
								(
									eachOption.availableChannels &&
									eachOption.availableChannels.indexOf('#' + selectedChannelType + '#') != -1
								)
								||
								(
									eachOption.hasOwnProperty(fieldToCheck) &&
									eachOption[fieldToCheck] === false &&
									(
										(
											e.detail.label && eachOption.parent === e.detail.label
										)
										||
										(
											e.detail.parent === 'Channel__c' &&
											this.allInputs()[destinationIndex - 1].inputPicklist.optionLabel === eachOption.parent
										)
									)
								)
							){
								x.push(eachOption);
							}
						}
						else if (eachOption.parent === e.detail.label || eachOption.value === "") {
							x.push(eachOption);
						}
					});

					this.writeLog('Field options to update: ' + x.length);

					destination.input.value = "";
					destination.displayOptions = x;
					destination.clearAdditionalInformation();
					destination.inputPicklist = {
						optionLabel: "",
						optionValue: "",
						fieldLabel: destination.field.fieldLabel,
						fieldName: destination.field.fieldName
					};

					if(x.length <= 1){
						destination.hidden = true;
						this.getElementsBySelector('.field-container')[destinationIndex].classList.add(
							'slds-hide', 'hidden-by-OptionSize'
						);
					}else{
						destination.hidden = false;
						this.getElementsBySelector('.field-container')[destinationIndex].classList.remove(
							'slds-hide', 'hidden-by-OptionSize'
						);
					}
				}

				this.writeLog('============ calculating hiding logic =============\n' + JSON.stringify(e.detail));
				this.handleFieldToggle(e, destination, hiddenIndex);
			});

			
		}
	}

	handleFieldToggle(e, destination, hiddenIndex) {
		this.writeLog('handleFieldToggle: ' + hiddenIndex);
		if (e.detail.parent && hiddenIndex && hiddenIndex >= 0) {
			/**
			 * Hide Additional Details section and set the Reason_Code_Details__c = "Adaptive"
			 * if the "Channel__c" is not "Tommy.com" OR "Calvin.com"
			 * if the "Reason_Code__c" is "Tommy Adaptive"
			 */
			let addDetailDiv = this.template.querySelectorAll('.field-container')[hiddenIndex];
			let hiddenDiv = this.allInputs()[hiddenIndex];
			this.writeLog('========================= addDetailDiv ========================= ' + addDetailDiv.classList);

			let hideClass = 'hidden-by-' + e.detail.parent.replace('__c', '');
			this.writeLog('========================= hideClass ========================= ' + hideClass);
			if(addDetailDiv.class.indexOf('hidden-by-OptionSize') === -1){
				addDetailDiv.classList.add(hideClass);

				//Check for change in Channel__c
				if (e.detail.parent === "Channel__c") {
					//Hide Additional detail if the picklist label is not a part of AD_SHOW_CHANNEL_LABELS
					if (AD_SHOW_CHANNEL_LABELS.indexOf(e.detail.label) === -1){
						addDetailDiv.classList.add("slds-hide");
						if (hiddenDiv) {
							hiddenDiv.hidden = true;
						}
					}
					else {
						//Check if the field is hidden by "Reason Code". IF YES, do nothing ELSE hide
						if (addDetailDiv.classList.contains("hidden-by-Reason_Code")) {
							addDetailDiv.classList.remove("hidden-by-Reason_Code")
						}
						addDetailDiv.classList.remove('slds-hide');
						addDetailDiv.classList.remove(hideClass);
						if (hiddenDiv) {
							hiddenDiv.hidden = false;
						}
					}
				}

				//Check for change in Reason_Code__c
				else if (e.detail.parent === "Reason_Code__c") {

					//Check if the field is hidden by channel. IF YES, do nothing ELSE hide
					if (!addDetailDiv.classList.contains("hidden-by-Channel")) {
						if (e.detail.label === "Tommy Adaptive") {
							this.writeLog('========================= found value ==================');
							addDetailDiv.classList.add('slds-hide');
							if (hiddenDiv) {
								hiddenDiv.hidden = true;
							}
						}
						else {
							addDetailDiv.classList.remove('slds-hide');
							addDetailDiv.classList.remove(hideClass);
							if (hiddenDiv) {
								hiddenDiv.hidden = false;
							}
						}
					}
				}
				this.writeLog('=========================after addDetailDiv ========================= ' + addDetailDiv.classList);
			}
		}
	}

	allInputs() {
		return this.template.querySelectorAll('c-nf-form-input');
	}

	namedInput(n) {
		return [...this.allInputs].find(f => f.field.fieldName === n);
	}

	getElementsBySelector(selector) {
		return this.template.querySelectorAll(selector);
	}

	submitForm() {
		if (this.formIsValid) {
			//Add Brand information in Brand__c field
			this.supportCase["Brand__c"] = this.formConfig.brand.brandCode;

			/**
			 * As the API Value for "Tommy Adaptive" and "Product Information" is "Product"; hence it's causing
			 * issue at the time of saving value for "Reason_Code_Details__c" field. Hence when field values are
			 * set on Case, we need to set a flag to do the distinction.
			*/
			let tommyAdaptiveFlag = false;

			let additionalInfo = '\n\n';
			this.allInputs().forEach(i => {
				this.supportCase[i.field.fieldName] = i.result.value;

				/**
				 * If "Brand_Name__c" is "Tommy Hilfiger", and "Reason_Code__c" is "Productive"; then check for
				 * the label of picklist. If the label is "Tommy Adaptive" then set "Reason_Code_Details__c" as "Adaptive".
				 * Else do nothing.
				 */

				if (this.brandname === "Tommy Hilfiger"
					&& i.field.fieldName === "Reason_Code__c"
					&& i.inputPicklist.optionLabel === "Tommy Adaptive") {
					//tommyAdaptiveFlag = true;
				}

				if (i.additionalInputInfo()) {
					//Append addition inputs information
					additionalInfo += i.additionalInputInfo();
				}
			});

			//Add additional information to Description
			this.supportCase["Description"] += additionalInfo;

			//Special exclusion process for Tommy Adaptive
			if (tommyAdaptiveFlag) {
				this.supportCase["Reason_Code_Details__c"] = "Adaptive";
			}

			if(this.singleBrandChannelValue && !this.supportCase["Channel__c"]){
				this.supportCase["Channel__c"] = this.singleBrandChannelValue;
			}

			this.writeLog('Case before insertion is: ' + JSON.stringify(this.supportCase));

			this.spinner = true;
			createCase({
				recordString: JSON.stringify(this.supportCase)
			}).then(res => {
				if (res.indexOf('SUCCESS') !== -1) {
					this.supportCase.CaseNumber = res.split(':')[1];
					this.caseGenerated = true;
					this.spinner = false;
				}
				else {
					this.writeLog('Error occurred: ' + res.split(':')[1]);
				}
			}).catch(err => {
				console.error('Operation failed: ' + err);
			})
		}
		else {
			this.writeLog('Form details are missing.');
		}
	}

	get formIsValid() {
		let allValid = true;
		this.writeLog('Number of elements: ' + this.allInputs().length);

		let reasonCode = "";

		this.allInputs().forEach((inputCmp) => {
			inputCmp.reportValidity();
			let fieldValidity = inputCmp.result.valid;

			//Special exclusion process for Tommy Adaptive
			if (inputCmp.field.fieldName === "Reason_Code__c") {
				reasonCode = inputCmp.result.value;
			}
			if (inputCmp.hidden === true) {
				fieldValidity = true;
			}
			this.writeLog('\n\t\t=======================================');
			this.writeLog('\t\tfield : ' + inputCmp.field.fieldLabel);
			this.writeLog('\t\tIs hidden field : ' + inputCmp.hidden);
			this.writeLog('\t\treasonCode : ' + reasonCode);
			this.writeLog('\t\tfieldValidity : ' + fieldValidity);
			this.writeLog('\t\t=======================================\n');

			allValid = allValid && fieldValidity;
		});
		return allValid;
	}

	handleUploadFinished(e) {
		let fileLimit = e.detail.files.length;
		let allNewFiles = [];
		var key = 0;
		this.writeLog('Files: ' + JSON.stringify(e.detail.files));

		for (let x = 0; x < fileLimit; x++) {
			let uploadedFile = e.detail.files[x];
			uploadedFile.key = ++key;

			if (x < 5) {
				this.filesToAttach.push(uploadedFile);
				this.supportCase.filesToRelate.push(uploadedFile);
			}
			else {
				this.supportCase.filesToDelete.push(uploadedFile);
			}
			allNewFiles.push(e.detail.files[x]);
		}

		this.writeLog('Files: ' + JSON.stringify(allNewFiles));

		//Call apex to update the description
		if (allNewFiles.length > 0) {
			updateFileDescription({
				fileObject : JSON.stringify(allNewFiles)
			}).then(res => {
				console.log(res);
			}).catch(err => {
				console.log('File description update failed.');
				console.log(err);
			})
		}

		this.writeLog('Files to attach: ' + JSON.stringify(this.filesToAttach));
		this.writeLog('Files to attach: ' + this.filesToAttach.length);
		this.writeLog('Files to remove: ' + this.supportCase.filesToDelete.length);
	}

	get maxFilesReached() {
		this.writeLog('maxFilesReached: ' + this.filesToAttach.length);
		return this.filesToAttach.length >= 5;
	}

	get showAttachments() {
		this.writeLog('showAttachments: ' + this.filesToAttach.length);
		return this.filesToAttach.length > 0;
	}

	removeFile(e) {
		let fileToDeleteIndex = parseInt(e.target.dataset.index);

		//Mark the already uploaded file for DELETION
		this.supportCase.filesToDelete.push(this.filesToAttach[fileToDeleteIndex]);

		//Remove the uploaded from attachement array
		this.filesToAttach.splice(fileToDeleteIndex, 1);

		//Refresh filesToRelate array
		this.supportCase.filesToRelate = [];
		this.filesToAttach.forEach(f => {
			this.supportCase.filesToRelate.push(f);
		})

		//Enable the file Upload feature
		if (this.filesToAttach.length < 5) {
			this.template.querySelector('.form-input-file').disabled = false;
		}

		//Files to delete
		this.supportCase.filesToDelete.forEach(f => {
			this.writeLog('Delete Name: ' + f.name);
		});

		//Files to delete
		this.filesToAttach.forEach(f => {
			this.writeLog('Attach name: ' + f.name);
		});
	}

	handleFieldAddition(e) {
		this.writeLog('e.detail: ' + JSON.stringify(e.detail));

		//Add new fields
		if (e.detail.source) {
			let parentIndex = this.fields.findIndex(f => f.fieldName === e.detail.source);
			if (parentIndex !== -1) {
				let ob = e.detail.payload;
				ob.additional = true;
				this.fields.splice(parentIndex + 1, 0, this.addFieldValidation(ob));
			}
		}
	}

	//Custom Logging method where logging can be toggled using "LOG_DATA"
	writeLog(x) {
		if (LOG_DATA) {
			console.log(x);
		}
	}
}