/******************************************************************************
 * @Description: SMSSubscriberSignUp from SFMC to SFSC
 * @Author      :
 * @Date          : 3 March
 * @JIRA          : NASSC-1519
 *
 ******************************************************************************/
@RestResource(urlmapping = '/SMSSubscriber/SignUp')
global without sharing class SMSSubscriberSignUp{
    static Id emailRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    global class SMSRequest{
        public String brandId;
        public String emailAddress;
        public String smsNumber;
        public Boolean loyaltyOptin;
        public String storeOfCapture;
        public String locale;
    }

    global class SMSResponse{
        public String code;
        public String message;
        public String ContactId;
        public String LoyaltyId;
        public String countryOfCapture;
    }

    @HttpPost
    global static SMSResponse doSMSSignUp(){


        Contact SMSMatchedContact = new Contact();
        Contact emailMatchedContact = new Contact();
        Boolean smsAndEmailExactMatch = false;
        //       Id siblingContactParentId;
        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();

        Contact newContact;
        Contact toBeUpdatedContact;

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String requestData = request.requestBody.toString();
        Log.push('***got request data = ' + requestData);

        SMSRequest smsRequest = (SMSRequest)JSON.deserialize(requestData, SMSRequest.class);
        Log.push('***SMS Request = ' + smsRequest);
        SMSResponse errorResponse = new SMSResponse();
        SMSResponse successResponse = new SMSResponse();
        Boolean isRequiredParameterMissing = false;

        if (String.isBlank(smsRequest.brandId) || String.isBlank(smsRequest.emailAddress) || String.isBlank(smsRequest.smsNumber) || //String.isEmpty(smsRequest.loyaltyOptin) ||    //fix this..
        String.isBlank(smsRequest.storeOfCapture)){
            isRequiredParameterMissing = true;
        }


        if (isRequiredParameterMissing){
            response.statusCode = 400;
            errorResponse.code = SYSTEM.LABEL.MISSING_PARAMETERS;
            errorResponse.Message = SYSTEM.LABEL.Missing_one_or_more_of_the_required_parameters_missing;
            Log.push('### errorResponse' + errorResponse);
            return errorResponse;
        }


        if (!isRequiredParameterMissing){
            //find brandId and SMSNumber Matched Contact
            SMSMatchedContact = SFMCUtility.searchSMSBrandContact(smsRequest.brandId, smsRequest.smsNumber);
            if (SMSMatchedContact != null && SMSMatchedContact.Email != null && SMSMatchedContact.Email == smsRequest.emailAddress)
                smsAndEmailExactMatch = true;
            if (smsAndEmailExactMatch){

                response.statusCode = 200;
                errorResponse.code = SYSTEM.LABEL.INVALID_SCENARIO;
                errorResponse.Message = SYSTEM.LABEL.Exact_match_on_email_SMS_Number_found_nothing_to_update;
                Log.push('### errorResponse' + errorResponse);
                return errorResponse;

            }
            if (!smsAndEmailExactMatch){
                emailMatchedContact = SFMCUtility.searchEmailBrandContact(smsRequest.brandId, smsRequest.emailAddress);
                //               siblingContactParentId = getSiblingAccountId(smsRequest.brandId, smsRequest.emailAddress);
            }

            if (SMSMatchedContact == null){
                //no SMSMatch scenarios

                if (emailMatchedContact == null){
                    Log.push('scenario optin#1');
                    //optin#1 - create new SMS+email Contact, optin.
                    newContact = createNewSMSAndEmailContact(smsRequest);
                    // trigger to assign new/existing account on insert.


                } else{

                    if (emailMatchedContact.SMSNumber__c == null){
                        Log.push('scenario optin#2');
                        //optin#2 - update email Contact with SMS, SMS Optin
                        emailMatchedContact.SMSNumber__c = smsRequest.smsNumber;
                        emailMatchedContact.SMSOptInDate__c = System.now();
                        if (emailMatchedContact.SMSLocale__c != smsRequest.locale){
                            emailMatchedContact.SMSLocale__c = smsRequest.locale;
                        }
                         //GCT-1571- Matching of Keyword  
                       if(emailMatchedContact.Keyword__c!=smsRequest.storeOfCapture){
                        emailMatchedContact.Keyword__c=smsRequest.storeOfCapture;
                       }
                        emailMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                        emailMatchedContact.Latest_Source__c = SYSTEM.LABEL.SFMC;
                        toBeUpdatedContact = emailMatchedContact;

                    } else{
                        Log.push('scenario optin#3');
                        //optin#3 - create new SMS only contact
                        newContact = createNewSMSOnlyContact(smsRequest);
                        newContact.AccountId = emailMatchedContact.AccountId;
                        if (emailMatchedContact.SMSLocale__c != smsRequest.locale){
                            emailMatchedContact.SMSLocale__c = smsRequest.locale;
                        }
                        //GCT-1571- Matching of Keyword  
                       if(emailMatchedContact.Keyword__c!=smsRequest.storeOfCapture){
                        emailMatchedContact.Keyword__c=smsRequest.storeOfCapture;
                       }
                    }
                }

            } else{
                // SMSMatchedContact exist scenarios

                if (SMSMatchedContact.Email == null && emailMatchedContact == null){
                    Log.push('scenario Reoptin#5');
                    // no email match contact
                    //Reoptin#5 - - update SMS Contact with email & SMS optin

                    SMSMatchedContact.SMSOptInDate__c = System.now();
                    SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                    SMSMatchedContact.Email = smsRequest.emailAddress;
                    SMSMatchedContact.Latest_Source__c = SYSTEM.LABEL.SFMC;
                    if (SMSMatchedContact.SMSLocale__c != smsRequest.locale){
                        SMSMatchedContact.SMSLocale__c = smsRequest.locale;
                    }
                    //GCT-1571- Matching of Keyword  
                    if(SMSMatchedContact.Keyword__c!=smsRequest.storeOfCapture){
                        SMSMatchedContact.Keyword__c=smsRequest.storeOfCapture;
                     }

                    toBeUpdatedContact = SMSMatchedContact;


                } else if (!smsAndEmailExactMatch){
                    Log.push('scenarios Reoptin#1,#2,#3,#4,#6 & #7');
                    //email match contact also exists
                    //Reoptin#1,#2,#3,#4,#6 & #7 - update SMS Contact with SMS Optin
                    SMSMatchedContact.SMSOptInDate__c = System.now();
                    SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                    SMSMatchedContact.Latest_Source__c = SYSTEM.LABEL.SFMC;
                    if (SMSMatchedContact.SMSLocale__c != smsRequest.locale){
                        SMSMatchedContact.SMSLocale__c = smsRequest.locale;
                    }
                    //GCT-1571- Matching of Keyword  
                    if(SMSMatchedContact.Keyword__c!=smsRequest.storeOfCapture){
                        SMSMatchedContact.Keyword__c=smsRequest.storeOfCapture;
                       }
                    toBeUpdatedContact = SMSMatchedContact;


                }


            }

            Contact responseContact;
            if (newContact != null){
                insert newContact;


                responseContact = [select Id, Latest_Source__c, Brand_Id__c, LoyaltyID__c, CountryOfCapture__c
                                   from Contact
                                   where Id = :newContact.id];
                Log.push('### newContact' + responseContact);

            } else if (toBeUpdatedContact != null){
                update toBeUpdatedContact;
                responseContact = toBeUpdatedContact;
                Log.push('### updatedContact' + responseContact);
            }


            if (responseContact != null){

                /* commeneted: this functionality handled by PB + invocable apex
                 signUpActivityList.add(SignUpActivity.signupActivity(responseContact.Id, responseContact.Latest_Source__c, responseContact.Brand_Id__c));
                 if(signUpActivityList.size()>0) SignUpActivity.logSignUpActivity(signUpActivityList);
                 */

                response.statusCode = 200;
                successResponse.code = SYSTEM.LABEL.OK;
                successResponse.Message = SYSTEM.LABEL.OK;
                successResponse.ContactId = responseContact.Id;
                if (responseContact.LoyaltyID__c != null)
                    successResponse.LoyaltyId = responseContact.LoyaltyID__c;
                if (responseContact.CountryOfCapture__c != null)
                    successResponse.countryOfCapture = responseContact.CountryOfCapture__c;
                Log.push('### successResponse' + successResponse);
                return successResponse;

            }


        }

        Logger.logDebug();
        return successResponse;
    }

    public static Contact createNewSMSOnlyContact(SMSRequest smsRequest){
        Contact newCon = new Contact();
        newCon.createdByMethod__c = SYSTEM.LABEL.API;
        newCon.RecordTypeId = emailRecordTypeId;
        newCon.Status__c = SYSTEM.LABEL.Active;
        newCon.Source_System__c = SYSTEM.LABEL.SFMC;
        newCon.Latest_Source__c = SYSTEM.LABEL.SFMC;
        newCon.Brand_Id__c = smsRequest.brandId;
        newCon.SMSLocale__c = smsRequest.locale;
        /* GCT-1571 */
        newCon.Keyword__c  =smsRequest.StoreOfCapture; 
        newCon.FirstName = SYSTEM.LABEL.Unknown;
        newCon.LastName = SYSTEM.LABEL.Unknown;

        newCon.SMSNumber__c = smsRequest.smsNumber;
        newCon.SMSOptinStatus__c = SYSTEM.LABEL.Y;
        newCon.SMSOptInDate__c = System.now();
        newCon.PVHCreatedDate__c = System.now();

        if (String.isNotBlank(smsRequest.StoreOfCapture))
            newCon.StoreOfCapture__c = smsRequest.StoreOfCapture;
        if (smsRequest.loyaltyOptin){
            newCon.LoyaltyFlag__c = true;
            newCon.Loyalty_Optin_Date__c = System.now();
        }


        return newCon;
    }

    public static Contact createNewSMSAndEmailContact(SMSRequest smsRequest){
        Contact newCon = createNewSMSOnlyContact(smsRequest);
        newCon.Email = smsRequest.emailAddress;
        newCon.EmailOptInStatus__c = SYSTEM.LABEL.N;
        return newCon;
    }

}