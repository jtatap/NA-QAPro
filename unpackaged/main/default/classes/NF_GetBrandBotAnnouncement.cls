/**
 * Created by samuel on 6/10/21.
 */
public without sharing class NF_GetBrandBotAnnouncement{
    public class Input{
        @InvocableVariable(required = true)
        public String Brand_API_Name;
    }

    public class Output{
        @InvocableVariable(required = false)
        public Boolean announcementFound = false;
        @InvocableVariable(required = false)
        public String announcement;
    }

    @InvocableMethod(label = 'NeuraFlash - Get Brand Announcement')
    public static List<Output> getAnnouncement(List<Input> inputs){
        Input input = inputs[0];
        Output out = new Output();

        Date today = Date.today();

        Brand_Bot_Announcement__c[] botAnnouncementsToDisplay = new List<Brand_Bot_Announcement__c>();

        if (test.isRunningTest()){
            if (input.Brand_API_Name == SYSTEM.LABEL.Speedo)
                today = today.addDays(1);
            else if (input.Brand_API_Name == SYSTEM.LABEL.IZOD)
                today = today.addDays(10);
            Log.push('>>> "TODAY" IS >>> ' + today);
        }
        botAnnouncementsToDisplay = [SELECT Announcement__c
                                     FROM Brand_Bot_Announcement__c
                                     WHERE Announcement_Start_Date__c <= :today AND Announcement_End_Date__c >= :today AND Brand__c = :input.Brand_API_Name
                                     ORDER BY LastModifiedDate DESC
                                     LIMIT 1];

        Log.push('botAnnouncementsToDisplay'+botAnnouncementsToDisplay);

        if (botAnnouncementsToDisplay.size() > 0){
            out.announcementFound = true;
            out.announcement = botAnnouncementsToDisplay[0].Announcement__c;
        }
        Logger.logDebug();
        return new List<Output>{ out };
    }

}