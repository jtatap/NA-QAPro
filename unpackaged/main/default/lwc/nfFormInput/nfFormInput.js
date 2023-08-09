import { LightningElement, api, track } from 'lwc';

const LOG_DATA = false;

export default class NfFormInput extends LightningElement {
	@api
	field = {
		fieldLabel : '',
		fieldName : '',
		fieldValue : '',
		fieldOptions : [],
		disabled: false
	};

	@api
	hidden = false;

	@api brandInfo = {};

	@api
	inputPicklist = {};

	@api
	displayOptions = [];
	@track inputs = [];
	@api selectedChannelType = '';

	connectedCallback() {
		if (this.isPicklist) {
			this.displayOptions = this.field.fieldOptions.filter(op => op.show === true);
		}
	}

	get isText() {
		return this.field.fieldType === 'STRING' || this.field.fieldType === 'EMAIL';
	}

	get isPicklist() {
		return this.field.fieldType === 'PICKLIST';
	}

	get isTextArea() {
		return this.field.fieldType === 'TEXTAREA';
	}

	@api
	get input() {
		return this.template.querySelector('.form-input');
	}

	get ComplexPayload() {
		return this.inputs;
	}

	handlePicklistChange(e) {
		let el = this.input;
		let text = el.options[el.selectedIndex].innerText;
		let developerName = el.options[el.selectedIndex].dataset.id;
		let selectedOption = this.field.fieldOptions.find(f => (f.label === text && (this.field.fieldName === 'Reason_Code_Details__c' ? f.developerName === developerName : true)));
		let secondaryAction = selectedOption ? selectedOption.secondaryAction : '';

		this.dispatchEvent(new CustomEvent('optionchange', {
			detail: {
				parent: this.field.fieldName,
				label: text,
				value: e.target.value,
				secondaryAction: secondaryAction,
				type: selectedOption ? selectedOption.type : ''
			}
		}));

		this.inputPicklist = {
			optionLabel: text,
			optionValue: e.target.value,
			fieldLabel: this.field.fieldLabel,
			fieldName: this.field.fieldName
		}

		//Clear previous elements from DOM
		this.clearAdditionalInformation();

		this.writeLog('Cleared: ' + JSON.stringify(this.inputs));
		let selectedChannelType = this.selectedChannelType

		//Assign new elements
		if (selectedOption) {
			let addInfo = this.field.fieldName == 'Reason_Code_Details__c' ?
				((selectedChannelType == 'Retail' ? selectedOption.additionalRetail : (
					selectedChannelType == 'Other Retailer' ? selectedOption.additionalOtherRetail : selectedOption.information
				)) || '') : selectedOption.information;
			let key = 0;
			try {
				//If the information is parsed properly using JSON.parse then its complex
				let payload = JSON.parse(addInfo);
				for (let c in payload) {
					let type = c;
					payload[c].forEach(ip => {
						if (type !== "fields") {
							let ob = {};
							ob.isText = type === "message";

							if (ob.isText) {
								ob.value = this.updatePlaceholderInfo(ip)
							}
							else if (ip.type === "radio") {
								ob = ip;
								ob.isRadio = true;
							}
							else {
								ob = ip;
								ob.isInput = type === "inputs";
							}
							ob.key = key;
							key++;
							this.inputs.push(ob);
						}
						else {
							this.dispatchEvent(new CustomEvent('fieldaddition', {
								detail: {
									source: this.field.fieldName,
									payload:ip
								}
							}));
						}
					});
				}
			}
			catch (ex) {
				let ob = {
					value: this.updatePlaceholderInfo(addInfo),
					isText: true
				}
				ob.key = key;
				key++;
				this.inputs.push(ob);
				this.writeLog(JSON.stringify(ex));
			}
			this.writeLog('>>> ' + JSON.stringify(this.inputs));
		}

		//Report validity to show or remove error on value change
		this.reportValidity();
	}

	updatePlaceholderInfo(infoText) {
		this.writeLog('updatePlaceholderInfo>> ' + JSON.stringify(this.brandInfo));
		this.writeLog('updatePlaceholderInfo>> ' + infoText);
		if (infoText) {
			if (infoText.indexOf("BRAND_ORDER_TRACK_LINK") !== -1) {
				infoText = infoText.replaceAll('BRAND_ORDER_TRACK_LINK', this.brandInfo.orderTrackerLink);
			}
			if (infoText.indexOf("BRAND_ORDER_STAUS_LINK") !== -1) {
				infoText = infoText.replaceAll('BRAND_ORDER_STAUS_LINK', this.brandInfo.orderStatusLink);
			}
			if (infoText.indexOf("BRAND_PASSWORD_RESET_LINK") !== -1) {
				infoText = infoText.replaceAll('BRAND_PASSWORD_RESET_LINK', this.brandInfo.passwordResetLink);
			}
		}
		this.writeLog('updatePlaceholderInfo>> ' + infoText);
		return infoText;
	}

	@api
	clearAdditionalInformation() {
		//Clear previous values
		this.inputs = [];
	}

	@api
	additionalInputInfo() {
		let info = '';
		let additionalInputs = this.template.querySelectorAll('.additional-field');
		if (additionalInputs.length > 0) {
			additionalInputs.forEach(ip => {
				if (ip.type === 'checkbox') {
					info += (ip.label + ' : ' + (ip.checked ? 'Yes' : 'No'));
				}
				else if(ip.type === 'text'){
					info += (ip.label + ' : ' + ip.value)
				}
				else if (ip.type === 'radio') {
					if (ip.checked) {
						info += (ip.name + ' : ' + ip.value);
					}
				}
				info += '\n\n';
			});
		}
		return info;
	}

	get validity() {
		let validity = this.input.validity.valid;
		if (this.isPicklist) {
			validity = this.field.isRequired && this.input.value !== "";
		}
		return validity;
	}

	@api
	get result() {
		return {
			value: this.input.value,
			valid: this.validity
		}
	}

	@api
	reportValidity() {
		if (this.isPicklist) {
			if (!this.validity) {
				this.input.classList.add('form-picklist-error');
			}
			else {
				this.input.classList.remove('form-picklist-error');
			}
		}
		else {
			this.input.reportValidity();
		}
	}

	//Custom Logging method where logging can be toggled using "LOG_DATA"
	writeLog(x) {
		if (LOG_DATA) {
			console.log(x);
		}
	}
}