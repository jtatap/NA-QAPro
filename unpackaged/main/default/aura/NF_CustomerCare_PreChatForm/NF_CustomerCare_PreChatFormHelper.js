/**
 * Created by mcasella on 9/11/20.
 */

({
    /**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
	 */
    fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName"
    },
    
    /**
	 * Event which fires the function to start a chat request (by accessing the chat API component)
	 *
	 * @param cmp - The component for this state.
	 */
    onStartButtonClick: function(component, event, helper) {
        fields = [];
        fields.push({label: 'First Name', name: 'FirstName', value: 'Chat'});
        fields.push({label: 'Last Name',  name: 'LastName',  value: 'User'});

        component.find("prechatAPI").startChat(fields);
        
        if (helper.preChatFieldsValidation(component)) {
            component.find("prechatAPI").startChat();

            var prechatFieldComponents = component.find("prechatField");
            var fields;
            
            // Make an array of field objects for the library
            fields = this.createFieldsArray(prechatFieldComponents);
            
            var firstname = component.get("v.FirstName");
            var lastname  = component.get("v.LastName");
            
            fields = [];

            // If the pre-chat fields pass validation, start a chat
            if(component.find("prechatAPI").validateFields(fields).valid) {
                // check agent available
                var checkAgentAvailable = component.get("c.checkAgentAvailable");
                checkAgentAvailable.setCallback(this, function(response) {
                    var state = response.getState();
                    var returnWrap = response.getReturnValue();
                    if (state === "SUCCESS") {
                        if(returnWrap.isConnectToChat === 'true') {
                            // agent available, start chat
                            document.getElementById("preChatForm").style.display = 'block';
                            console.log('fields fields >> '+JSON.stringify(fields))
                            component.find("prechatAPI").startChat(fields);
                        }
                        else if(returnWrap.isConnectToChat === 'false') {
                            var isCustomMessageSet = returnWrap.showCustomMessage;
                            
                            if(isCustomMessageSet === 'true') {
                                component.set('v.showCustomMessage',true);
                                component.set('v.customMessage',returnWrap.customMessage);
                            }
                            else {
                                component.set('v.showCustomMessage',false);
                            }
                            if(document.getElementById("preChatForm")){
                                document.getElementById("preChatForm").style.display = 'none';
                            }
                            if(document.getElementById("chatUnavailable")){
                                document.getElementById("chatUnavailable").style.display = 'block';
                            }
                            
                        }
                        
                    }
                    
                    else {
                        // no agent available, display other msg
                        if(document.getElementById("preChatForm")){
                            document.getElementById("preChatForm").style.display = 'none';
                        }
                        if(document.getElementById("chatUnavailable")){
                            document.getElementById("chatUnavailable").style.display = 'block';
                        }
                    }
                });
                
                $A.enqueueAction(checkAgentAvailable);
                
            } else {
                console.warn("Prechat fields did not pass validation!");
            }
        }
    },
    
    preChatFieldsValidation : function(component) {
        let valid = true;
        
        var firstName = component.find("firstName");
        var lastName = component.find("lastName");
        
        if (firstName.get("v.validity").valueMissing) {
            firstName.setCustomValidity("This field is required");
            firstName.reportValidity();
            valid=false;
        }
        if (lastName.get("v.validity").valueMissing) {
            lastName.setCustomValidity("This field is required");
            lastName.reportValidity();
            valid=false;
        }
        
        return valid;
    },
    
    /**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 *
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
    createFieldsArray: function(fields) {
        if(fields.length) {
            return fields.map(function(fieldCmp) {
                return {
                    label: fieldCmp.get("v.label"),
                    value: fieldCmp.get("v.value"),
                    name: this.fieldLabelToName[fieldCmp.get("v.label")]
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    
    /**
     * Create an array in the format $A.createComponents expects
     *
     * Example:
     * [["componentType", {attributeName: "attributeValue", ...}]]
     *
	 * @param prechatFields - Array of pre-chat field Objects.
	 * @returns Array that can be passed to $A.createComponents
     */
    getPrechatFieldAttributesArray: function(prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        
        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) {
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var componentInfoArray = ["ui:" + componentName];
            var attributes = {
                "aura:id": "prechatField",
                required: field.required,
                label: field.label,
                disabled: field.readOnly,
                maxlength: field.maxLength,
                class: field.className,
                value: field.value
            };
            
            // Special handling for options for an input:select (picklist) component
            if(field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
            
            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);
            
            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
        });
        
        
        return prechatFieldsInfoArray;
    },
    
    
});