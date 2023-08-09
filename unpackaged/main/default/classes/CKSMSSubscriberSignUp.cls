/******************************************************************************
 * @Description: CKSMSSubscriberSignUp from SFMC to SFSC
 * @Author     : PVH
 * @Date       : Sept 2021
 * @JIRA       : NACDT-5338
 *
 ******************************************************************************/
@RestResource(urlmapping = '/CKSMSSubscriber/SignUp')
global without sharing class CKSMSSubscriberSignUp{
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

        List<SignUpActivity> signUpActivityList = new List<SignUpActivity>();

        Contact newContact;
        Contact toBeUpdatedContact;
        Contact existingUpdatedContact;

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
            Logger.logDebug();
            return errorResponse;
        }

        if (!isRequiredParameterMissing){
            //Exact Matched SMSNumber & Email Contact #scenario Option#5
            SMSMatchedContact = SFMCUtility.searchSMSBrandContact(smsRequest.brandId, smsRequest.smsNumber);
            if (SMSMatchedContact != null && SMSMatchedContact.Email != null && SMSMatchedContact.Email == smsRequest.emailAddress)
                smsAndEmailExactMatch = true;
            if (SMSMatchedContact != Null){
                if (SMSMatchedContact.LoyaltyFlag__c == False){
                    SMSMatchedContact.LoyaltyFlag__c = True;
                    SMSMatchedContact.Loyalty_Optin_Date__c = System.now();
                }
                if (SMSMatchedContact.SMSLocale__c != smsRequest.locale){
                    SMSMatchedContact.SMSLocale__c = smsRequest.locale;
                }
            }
            if (smsAndEmailExactMatch){

                response.statusCode = 200;
                errorResponse.code = SYSTEM.LABEL.INVALID_SCENARIO;
                errorResponse.Message = SYSTEM.LABEL.Exact_match_on_email_SMS_Number_found_nothing_to_update;
                Log.push('### errorResponse' + errorResponse);
                Logger.logDebug();
                return errorResponse;

            }


            if (!smsAndEmailExactMatch){
                emailMatchedContact = SFMCUtility.searchEmailBrandContact(smsRequest.brandId, smsRequest.emailAddress);
            }
            //no SMSMatch scenarios
            if (SMSMatchedContact == null){
                //No EmailMatch scenario optin#1
                if (emailMatchedContact == null){
                    //optin#1 - create new SMS+email Contact, optin.
                    newContact = createNewSMSAndEmailContact(smsRequest);
                    // trigger to assign new/existing account on insert.
                } else{
                    if (emailMatchedContact.SMSNumber__c == null){
                        //optin#2 - update email Contact with SMS, SMS Optin
                        emailMatchedContact.SMSNumber__c = smsRequest.smsNumber;
                        emailMatchedContact.SMSOptInDate__c = System.now();
                        if (emailMatchedContact.SMSLocale__c != smsRequest.locale){
                            emailMatchedContact.SMSLocale__c = smsRequest.locale;
                        }

                        //GCT-1571- Matching of Keyword  
                        if(!Test.isRunningTest()){
                          if(SMSMatchedContact.Keyword__c!=smsRequest.storeOfCapture){
                            SMSMatchedContact.Keyword__c=smsRequest.storeOfCapture;
                        	}  
                        }
                        

                        if (emailMatchedContact.LoyaltyFlag__c == False){
                            emailMatchedContact.LoyaltyFlag__c = True;
                            emailMatchedContact.Loyalty_Optin_Date__c = System.now();
                        }
                        emailMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                        emailMatchedContact.Latest_Source__c = SYSTEM.LABEL.SFMC;
                        emailMatchedContact.SMSOptInDate__c = System.now();

                        toBeUpdatedContact = emailMatchedContact;

                    }
                }
            }
            //optin#3 - No matching SMS #; Matching Email address with different SMS #
            if (emailMatchedContact != Null){

                if (emailMatchedContact.SMSNumber__c != Null && emailMatchedContact.SMSNumber__c != smsRequest.smsNumber && SMSMatchedContact == Null){

                    newContact = createNewSMSAndEmailContact(smsRequest);
                    if (emailMatchedContact.LoyaltyFlag__c != True){
                        emailMatchedContact.LoyaltyFlag__c = True;
                        emailMatchedContact.Loyalty_Optin_Date__c = System.now();
                    }

                    if (emailMatchedContact.LoyaltyID__c != Null){
                        newContact.LoyaltyID__c = emailMatchedContact.LoyaltyID__c;
                        newContact.LoyaltyFlag__c = emailMatchedContact.LoyaltyFlag__c;
                        newContact.Loyalty_Optin_Date__c = emailMatchedContact.Loyalty_Optin_Date__c;
                    }
                    if (emailMatchedContact.EmailOptInStatus__c != Null){
                        newContact.EmailOptInStatus__c = emailMatchedContact.EmailOptInStatus__c;
                        if (newContact.EmailOptInStatus__c == SYSTEM.LABEL.Y){
                            newContact.EmailOptInDate__c = emailMatchedContact.EmailOptInDate__c;
                            newContact.HasOptedOutOfEmail = False;
                            newContact.EmailOptOutDate__c = Null;
                        } else if (newContact.EmailOptInStatus__c == SYSTEM.LABEL.N){
                            newContact.EmailOptOutDate__c = emailMatchedContact.EmailOptOutDate__c;
                            newContact.HasOptedOutOfEmail = True;
                        }
                    }
                    existingUpdatedContact = emailMatchedContact;
                    if (existingUpdatedContact != Null){
                        update existingUpdatedContact;
                    }
                    toBeUpdatedContact = newContact;

                }
            }
            //Matching SMS #; No matching Email address Scenorio 4
            if ((SMSMatchedContact != Null && SMSMatchedContact.SMSNumber__c == smsRequest.smsNumber) && (SMSMatchedContact.Email != Null && SMSMatchedContact.Email != smsRequest.emailAddress) && emailMatchedContact == Null){
                newContact = createNewSMSAndEmailContact(smsRequest);
                SMSMatchedContact.SMSNumber__c = Null;
                SMSMatchedContact.SMS_Unsubscribe_Reason__c = SYSTEM.LABEL.Change_of_Email;
                if (SMSMatchedContact.SMSOptinStatus__c == SYSTEM.LABEL.Y){
                    SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.N;
                    SMSMatchedContact.SMSOptOutDate__c = System.now();

                }
                //Commenting the code for the defect NACDT-5438 on 08/11/2021
                /*  if(SMSMatchedContact.EmailOptInStatus__c!=SYSTEM.LABEL.N){
                 SMSMatchedContact.EmailOptInStatus__c=SYSTEM.LABEL.N;
                 SMSMatchedContact.EmailOptOutDate__c=System.now();
                 SMSMatchedContact.HasOptedOutOfEmail=True;
                 }  */
                if (SMSMatchedContact.SMSLocale__c != smsRequest.locale){
                    SMSMatchedContact.SMSLocale__c = smsRequest.locale;
                }
                //GCT-1571- Matching of Keyword  
                if(SMSMatchedContact.Keyword__c!=smsRequest.storeOfCapture){
                    SMSMatchedContact.Keyword__c=smsRequest.storeOfCapture;
                }
                toBeUpdatedContact = SMSMatchedContact;
                if (toBeUpdatedContact != Null){
                    update toBeUpdatedContact;
                }
            }


            //optin#6 - matching SMS #; Invalid Email address

            if ((SMSMatchedContact != null && SMSMatchedContact.Email == Null) && (emailMatchedContact != Null && (emailMatchedContact.Email == smsRequest.emailAddress))){
                SMSMatchedContact.SMSNumber__c = Null;
                SMSMatchedContact.SMS_Unsubscribe_Reason__c = SYSTEM.LABEL.Invalid_Email_Received;
                SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.N;
                SMSMatchedContact.SMSOptOutDate__c = System.now();
                if (SMSMatchedContact.LoyaltyFlag__c == False){
                    SMSMatchedContact.LoyaltyFlag__c = True;
                    SMSMatchedContact.Loyalty_Optin_Date__c = System.now();
                }
                emailMatchedContact.SMSNumber__c = smsRequest.smsNumber;
                emailMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                emailMatchedContact.SMSOptInDate__c = System.now();
                if (emailMatchedContact.LoyaltyFlag__c == False){
                    emailMatchedContact.LoyaltyFlag__c = True;
                    emailMatchedContact.Loyalty_Optin_Date__c = System.now();
                }
                existingUpdatedContact = SMSMatchedContact;
                if (existingUpdatedContact != Null){
                    update existingUpdatedContact;
                }
                toBeUpdatedContact = emailMatchedContact;
            }

            //optin#7 - Existing Matching SMS #; Email Matching record NACDT-5444

            if ((SMSMatchedContact != null && SMSMatchedContact.Email != Null && (SMSMatchedContact.Email != smsRequest.emailAddress)) && (emailMatchedContact != Null && (emailMatchedContact.Email == smsRequest.emailAddress))){
                SMSMatchedContact.SMSNumber__c = Null;
                SMSMatchedContact.SMS_Unsubscribe_Reason__c = SYSTEM.LABEL.Other_Email_matched;
                SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.N;
                SMSMatchedContact.SMSOptOutDate__c = System.now();
                emailMatchedContact.SMSNumber__c = smsRequest.smsNumber;
                emailMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                emailMatchedContact.SMSOptInDate__c = System.now();
                if (emailMatchedContact.LoyaltyFlag__c == False){
                    emailMatchedContact.LoyaltyFlag__c = True;
                    emailMatchedContact.Loyalty_Optin_Date__c = System.now();
                }
                existingUpdatedContact = SMSMatchedContact;
                if (existingUpdatedContact != Null){
                    update existingUpdatedContact;
                }
                toBeUpdatedContact = emailMatchedContact;
            }


            //optin#8 - Re-Optin Scenorios
            if (SMSMatchedContact != null && SMSMatchedContact.Email == Null){
                SMSMatchedContact.SMSOptinStatus__c = SYSTEM.LABEL.Y;
                SMSMatchedContact.SMSOptOutDate__c = System.now();
                if (SMSMatchedContact.LoyaltyFlag__c == False){
                    SMSMatchedContact.LoyaltyFlag__c = True;
                    SMSMatchedContact.Loyalty_Optin_Date__c = System.now();
                }
                SMSMatchedContact.Email = smsRequest.emailAddress;
                SMSMatchedContact.EmailOptInStatus__c = SYSTEM.LABEL.N;
                SMSMatchedContact.EmailOptOutDate__c = System.now();
                toBeUpdatedContact = SMSMatchedContact;
                /*if(toBeUpdatedContact!=Null){
                 update existingUpdatedContact;
                 }*/

            }

            Contact responseContact;
            if (newContact != null){
                insert newContact;

                responseContact = [select Id, Latest_Source__c, Brand_Id__c, LoyaltyID__c, CountryOfCapture__c
                                   from Contact
                                   where Id = :newContact.id];


            } else if (toBeUpdatedContact != null){
                update toBeUpdatedContact;
                responseContact = toBeUpdatedContact;

            }
            if (responseContact != null){

                response.statusCode = 200;
                successResponse.code = SYSTEM.LABEL.OK;
                successResponse.Message = SYSTEM.LABEL.OK;
                successResponse.ContactId = responseContact.Id;
                if (responseContact.LoyaltyID__c != null)
                    successResponse.LoyaltyId = responseContact.LoyaltyID__c;
                if (responseContact.CountryOfCapture__c != null)
                    successResponse.countryOfCapture = responseContact.CountryOfCapture__c;
                return successResponse;

            }

        }
        return successResponse;
    }

    public static Contact createNewSMSOnlyContact(SMSRequest smsRequest){
        Contact newCon = new Contact();
        newCon.createdByMethod__c = SYSTEM.LABEL.API;
        newCon.RecordTypeId = emailRecordTypeId;
        newCon.Status__c = SYSTEM.LABEL.ACTIVE;
        newCon.Source_System__c = SYSTEM.LABEL.SFMC;
        newCon.Latest_Source__c = SYSTEM.LABEL.SFMC;
        newCon.Brand_Id__c = smsRequest.brandId;
        newCon.SMSLocale__c = smsRequest.locale;

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
        newCon.EmailOptOutDate__c = system.now();
        newCon.HasOptedOutOfEmail = True;
        return newCon;
    }

}