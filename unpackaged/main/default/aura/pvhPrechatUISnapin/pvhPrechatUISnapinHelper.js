/**
 * Created by bryananderson on 2019-08-28.
 */

({
    /**
     * Map of pre-chat field label to pre-chat field name (can be found in Setup)
     */
    fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Email": "Email",
        "Phone": "Phone",
        "Fax": "Fax",
        "Mobile": "MobilePhone",
        "Home Phone": "HomePhone",
        "Other Phone": "OtherPhone",
        "Asst. Phone": "AssistantPhone",
        "Title": "Title",
        "Lead Source": "LeadSource",
        "Assistant": "AssistantName",
        "Department": "Department",
        "Subject": "Subject",
        "Case Reason": "Reason",
        "Type": "Type",
        "Web Company": "SuppliedCompany",
        "Web Phone": "SuppliedPhone",
        "Priority": "Priority",
        "Web Name": "SuppliedName",
        "Web Email": "SuppliedEmail",
        "Company": "Company",
        "Industry": "Industry",
        "Rating": "Rating",
        "Brand": "Brand_Id__c",
        "CreatedByMethod": "CreatedByMethod__c",
        "CaseBrand": "Brand__c",
        "Account First Name": "FirstName",
        "Account Last Name": "LastName",
        "Case Origin": "Origin"
    },

    /**
     * Event which fires the function to start a chat request (by accessing the chat API component)
     *
     * @param cmp - The component for this state.
     */
    onStartButtonClick: function (component) {
        var prechatFieldComponents = component.find("prechatField");
        var apiNamesMap = this.createAPINamesMap(component.find("prechatAPI").getPrechatFields());
        var fields;

        // Make an array of field objects for the library.
        fields = this.createFieldsArray(prechatFieldComponents);

        // If the prechat fields pass validation, start a chat.
        if (component.find("prechatAPI").validateFields(fields).valid) {
            var caseFieldsEvent = new CustomEvent(
                "setCaseFields",
                {
                    detail: {
                        callback: component.find("prechatAPI").startChat.bind(this, fields),
                        webEmail: component.find('prechatField')[2].get('v.value'), //assumes 3rd field in Prechat setup is the Email field
                        webPhone: component.find('prechatField')[3].get('v.value'), //assumes 4th field in Prechat setup is the Phone field
                        webName: (component.find('prechatField')[0].get('v.value') + ' ' + component.find('prechatField')[1].get('v.value')),  //assumes 1st and 2nd fields in Prechat setup are the First Name and Last Name field
                        firstName: component.find('prechatField')[0].get('v.value'), //assumes 1st field in Prechat setup is the First Name field
                        lastName: component.find('prechatField')[1].get('v.value') //assumes 2nd field in Prechat setup is the Last Name field
                    }
                }
            );

            // Dispatch the event
            document.dispatchEvent(caseFieldsEvent);
            

        } else {
            console.warn("Prechat fields did not pass validation!");
        }
    },

    /**
     * Create an array of field objects to start a chat from an array of prechat fields.
     *
     * @param fields - Array of prechat field Objects.
     * @returns An array of field objects.
     */
    createFieldsArray: function (fields) {
        if (fields.length) {
            return fields.map(function (fieldCmp) {
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
    getPrechatFieldAttributesArray: function (prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];

        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function (field) {
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
            if (field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;

            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);

            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
        });

        return prechatFieldsInfoArray;
    },
    /**
     * Check that First Name and Last Name are populated
     *
     * @param @param cmp - The component for this state.
     */
    validateFields: function (component, event) {
        //Boolean variable to decide if all fields are populated or not
        var validationSuccessful = true;

        //Get all fields on the prechat form
        var prechatFieldComponents = component.find("prechatField");

        //Loop through each field. Leave the email field.
        for (var i = 0; i < prechatFieldComponents.length; i++) {
            var pcField = prechatFieldComponents[i];
            if (pcField.get("v.required")) {
                if (pcField.get("v.value") === null || pcField.get("v.value") === "" || pcField.get("v.value") === undefined) {
                    pcField.set("v.errors", [{message: $A.get("$Label.c.prechatRequiredField")}]);
                    validationSuccessful = false;
                } else {
                    pcField.set("v.errors", null);
                }

                //Email form validation
                if (pcField.get("v.label") === "Email") {
                    var regExpEmail = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

                    if (pcField.get("v.value") !== null && pcField.get("v.value") !== "" && pcField.get("v.value") !== undefined) {
                        if (pcField.get("v.value").match(regExpEmail)) {
                            pcField.set("v.errors", null);
                        } else {
                            pcField.set("v.errors", [{message: $A.get("$Label.c.prechatEmailInvalid")}]);
                            validationSuccessful = false;
                        }
                    }
                }

                //Subject form field data masking for credit cards
                //matches American Express, Visa, China UnionPay, Dankort, DinersClub, DinersClub CartBlanche, Discover, Instapayment, Interpayment, JCB, Maestro, Mastercard, Solo, UATP
                //substitutes the matching number with asterisks
                //matches as separate string and within a string as well as expected formatting on physical card with hyphens (-) or spaces
                if (pcField.get("v.label") === "Subject") {
                    var americanExpressRegEx1 = /\b(3[47]\d{2}[\.\_\s\-]*\d{6}[\.\_\s\-]*\d{5})\b|(\b3[47]\d{13})\b/gm;
                    var americanExpressRegEx2 = /\B(3[47]\d{2}[\.\_\s\-]*\d{6}[\.\_\s\-]*\d{5})\B|(\B3[47]\d{13})\B/gm;

                    var visaRegEx1 = /\b4((\d{3}[\.\_\s\-]*\d{3,4}[\.\_\s\-]*\d{3,4}[\.\_\s\-]*\d{4})|(d{3}[\.\_\s\-]*d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}))\b/gm;
                    var visaRegEx2 = /\B4((\d{3}[\.\_\s\-]*\d{3,4}[\.\_\s\-]*\d{3,4}[\.\_\s\-]*\d{4})|(d{3}[\.\_\s\-]*d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}))\B/gm;

                    var chinaUnionRegEx1 = /\b62\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var chinaUnionRegEx2 = /\B62\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var dankortRegEx1 = /\b5019[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var dankortRegEx2 = /\B5019[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var dinersClubRegEx1 = /\b3(0[0-59]\d{2}|[6]\d{3})[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{5}\b/gm;
                    var dinersClubRegEx2 = /\b3[89]\d{3}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{7}\b/gm;
                    var dinersClubRegEx3 = /\b3(?:0[0-5]|[68][0-9])[0-9]{11}\b/gm;
                    var dinersClubRegEx4 = /\B3(0[0-59]\d{2}|[6]\d{3})[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{5}\B/gm;
                    var dinersClubRegEx5 = /\B3[89]\d{3}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{7}\B/gm;
                    var dinersClubRegEx6 = /\B3(?:0[0-5]|[68][0-9])[0-9]{11}\B/gm;

                    var dinersClubCartBlancheRegEx1 = /\b30[0123459]\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{5}\b/gm;
                    var dinersClubCartBlancheRegEx2 = /\b30[12345]\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{5}\b/gm;
                    var dinersClubCartBlancheRegEx3 = /\b30[12345]\d{11}\b/gm;
                    var dinersClubCartBlancheRegEx4 = /\B30[0123459]\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{5}\B/gm;
                    var dinersClubCartBlancheRegEx5 = /\B30[12345]\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{5}\B/gm;
                    var dinersClubCartBlancheRegEx6 = /\B30[12345]\d{11}\B/gm;

                    var discoverRegEx1 = /\b6(?:011\d\d|5\d{4}|4[4-9]\d{3}|22(?:1(?:2[6-9]|[3-9]\d)|[2-8]\d\d|9(?:[01]\d|2[0-5])))\d{10}\b/gm;
                    var discoverRegEx2 = /\b6(011|5\d{2}|4[4-9]\d{1})[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var discoverRegEx3 = /\b622[19][\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var discoverRegEx4 = /\B6(?:011\d\d|5\d{4}|4[4-9]\d{3}|22(?:1(?:2[6-9]|[3-9]\d)|[2-8]\d\d|9(?:[01]\d|2[0-5])))\d{10}\B/gm;
                    var discoverRegEx5 = /\B6(011|5\d{2}|4[4-9]\d{1})[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;
                    var discoverRegEx6 = /\B622[19][\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var instapaymentRegEx1 = /\b63[789]\d{1}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var instapaymentRegEx2 = /\B63[789]\d{1}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var interpaymentRegEx1 = /\b636\d{1}[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}\b/gm;
                    var interpaymentRegEx2 = /\B636\d{1}[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}\B/gm;

                    var jcbRegEx1 = /\b35\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var jcbRegEx2 = /\B35\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var maestroRegEx1 = /\b(5[0678]\d{2}|(63[09][40])|6[189]\d{2})[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}\b/gm;
                    var maestroRegEx2 = /\B(5[0678]\d{2}|(63[09][40])|6[189]\d{2})[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}[\.\_\s\-]*\d{4,5}\B/gm;

                    var mastercardRegEx1 = /\b5[12345]\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var mastercardRegEx2 = /\B5[12345]\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var soloRegEx1 = /\b(6334|6767)(([\.\_\s\-]*\d{4,6}[\.\_\s\-]*\d{4,6}[\.\_\s\-]*\d{4,6})|([\.\_\s\-]*\d{5}[\.\_\s\-]*\d{5}[\.\_\s\-]*\d{4,6}))\b/gm;
                    var soloRegEx2 = /\B(6334|6767)(([\.\_\s\-]*\d{4,6}[\.\_\s\-]*\d{4,6}[\.\_\s\-]*\d{4,6})|([\.\_\s\-]*\d{5}[\.\_\s\-]*\d{5}[\.\_\s\-]*\d{4,6}))\B/gm;

                    var uatpRegEx1 = /\b1\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\b/gm;
                    var uatpRegEx2 = /\B1\d{2}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}[\.\_\s\-]*\d{4}\B/gm;

                    var value = pcField.get("v.value");
                    var subst = '****************';

                    var value1 = value.replace(americanExpressRegEx1, subst);
                    var value2 = value1.replace(americanExpressRegEx2, subst);

                    var value3 = value2.replace(visaRegEx1, subst);
                    var value4 = value3.replace(visaRegEx2, subst);

                    var value5 = value4.replace(chinaUnionRegEx1, subst);
                    var value6 = value5.replace(chinaUnionRegEx2, subst);

                    var value7 = value6.replace(dankortRegEx1, subst);
                    var value8 = value7.replace(dankortRegEx2, subst);

                    var value9 = value8.replace(dinersClubRegEx1, subst);
                    var value10 = value9.replace(dinersClubRegEx2, subst);
                    var value11 = value10.replace(dinersClubRegEx3, subst);
                    var value12 = value11.replace(dinersClubRegEx4, subst);
                    var value13 = value12.replace(dinersClubRegEx5, subst);
                    var value14 = value13.replace(dinersClubRegEx6, subst);

                    var value15 = value14.replace(dinersClubCartBlancheRegEx1, subst);
                    var value16 = value15.replace(dinersClubCartBlancheRegEx2, subst);
                    var value17 = value16.replace(dinersClubCartBlancheRegEx3, subst);
                    var value18 = value17.replace(dinersClubCartBlancheRegEx4, subst);
                    var value19 = value18.replace(dinersClubCartBlancheRegEx5, subst);
                    var value20 = value19.replace(dinersClubCartBlancheRegEx6, subst);

                    var value21 = value20.replace(discoverRegEx1, subst);
                    var value22 = value21.replace(discoverRegEx2, subst);
                    var value23 = value22.replace(discoverRegEx3, subst);
                    var value24 = value23.replace(discoverRegEx4, subst);
                    var value25 = value24.replace(discoverRegEx5, subst);
                    var value26 = value25.replace(discoverRegEx6, subst);

                    var value27 = value26.replace(instapaymentRegEx1, subst);
                    var value28 = value27.replace(instapaymentRegEx2, subst);

                    var value29 = value28.replace(interpaymentRegEx1, subst);
                    var value30 = value29.replace(interpaymentRegEx2, subst);

                    var value31 = value30.replace(jcbRegEx1, subst);
                    var value32 = value31.replace(jcbRegEx2, subst);

                    var value33 = value32.replace(maestroRegEx1, subst);
                    var value34 = value33.replace(maestroRegEx2, subst);

                    var value35 = value34.replace(mastercardRegEx1, subst);
                    var value36 = value35.replace(mastercardRegEx2, subst);

                    var value37 = value36.replace(soloRegEx1, subst);
                    var value38 = value37.replace(soloRegEx2, subst);

                    var value39 = value38.replace(uatpRegEx1, subst);
                    var value40 = value39.replace(uatpRegEx2, subst);

                    if (value !== null && value !== "" && value !== undefined) {
                        pcField.set("v.value", value40);
                    }
                }
            }

            //US Format Phone Number validation
            if (pcField.get("v.label") === "Phone") {
                var regExpUSPhone = /^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/;

                if (pcField.get("v.value") !== null && pcField.get("v.value") !== "" && pcField.get("v.value") !== undefined) {
                    if (pcField.get("v.value").match(regExpUSPhone)) {
                        pcField.set("v.errors", null);
                    } else {
                        pcField.set("v.errors", [{message: $A.get("$Label.c.prechatPhoneInvalid")}]);
                        validationSuccessful = false;
                    }
                }
            }
        }

        //Set the validation attribute. This is used for showing the UI:Message
        component.set("v.validationSuccessful", validationSuccessful);
    },
    /**
     * Create map of field label to field API name from the pre-chat fields array.
     *
     * @param fields - Array of prechat field Objects.
     * @returns An array of field objects.
     */
    createAPINamesMap: function (fields) {
        var values = {};

        fields.forEach(function (field) {
            values[field.label] = field.name;
        });

        return values;
    }
});