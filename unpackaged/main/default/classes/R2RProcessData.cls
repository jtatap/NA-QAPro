public class R2RProcessData {
    
    public string caseId{get;set;}
    public string emailAddress{get;set;}
    public string ChangedEmail{get;set;}
    public string ChangedFirstName{get;set;}
    public string ChangedLastName{get;set;}
    public string ChangedUnit{get;set;}
    public string ChangedCity{get;set;}
    public string ChangedCountry{get;set;}
    public string ChangedState{get;set;}
    public string ChangedZipCode{get;set;}
    public string ChangedPhone{get;set;}
    public string ChangedGender{get;set;}
    public string ChangedBirthDate{get;set;}
    public string approvalURL{get;set;}
    public string rejectedURL{get;set;}
    public string rectifiedData{get;set;}
    public string verificationHash{get;set;}
    public string privacyURLforRESTAPIResponse{get;set;}
    
    public void getProcessData(){
        approvalURL = PrivacyURLforRESTAPIResponse+'/services/apexrest/public/v1/r2rProcesss?in_response=Open&in_verificationCode='+VerificationHash+'&in_caseid='+CaseId;
        rejectedURL = PrivacyURLforRESTAPIResponse+'/services/apexrest/public/v1/r2rProcesss?in_response=Resolved&in_verificationCode='+VerificationHash+'&in_caseid='+CaseId;
        if(string.isNotEmpty(rectifiedData)){
            R2RWrapper wrap = (R2RWrapper)JSON.deserialize(rectifiedData,R2RWrapper.class);
            ChangedEmail = wrap.ChangedEmail;
            ChangedFirstName = wrap.ChangedFirstName;
            ChangedLastName = wrap.ChangedLastName;
            if(wrap.add!=null){
                ChangedUnit = wrap.add.ChangedUnit;
                ChangedCity = wrap.add.ChangedCity;
                ChangedCountry = wrap.add.ChangedCountry;
                ChangedState = wrap.add.ChangedState;
                ChangedZipCode = wrap.add.ChangedZipCode;
                ChangedPhone = wrap.add.ChangedPhone;
                ChangedGender = wrap.add.ChangedPhone;
                ChangedBirthDate = wrap.add.ChangedBirthDate;
            }
        }
    }
    
    public class R2RWrapper{
        public string ChangedEmail;
        public string ChangedFirstName;
        public string ChangedLastName;
        public Address add;
    }
    public class Address{
        public string ChangedUnit;
        public string ChangedCity;
        public string ChangedCountry;
        public string ChangedState;
        public string ChangedZipCode;
        public string ChangedPhone;
        public string ChangedGender;
        public string ChangedBirthDate;
    }
    
}