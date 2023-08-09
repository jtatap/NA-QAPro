/**
 * Created by samuel on 6/10/21.
 */
@IsTest(isParallel=false)
public with sharing class NF_GetBrandBotAnnouncementTest {

    @TestSetup
    public static void setupAnnouncements() {
        Date today = Date.today();

        
        Brand_Bot_Announcement__c[] testAnnouncements = new List<Brand_Bot_Announcement__c>();

        Brand_Bot_Announcement__c announcement_success = new Brand_Bot_Announcement__c();
        announcement_success.Announcement__c = 'This is a test announcement';
        announcement_success.Announcement_End_Date__c = today;
        announcement_success.Announcement_Start_Date__c = today;
        announcement_success.Brand__c = 'Calvin Klein';
        testAnnouncements.add(announcement_success);
        //insert announcement_success;

        Brand_Bot_Announcement__c announcement_success2 = new Brand_Bot_Announcement__c();
        announcement_success2.Announcement__c = 'This is a test announcement, running over 3 days and overlapping today';
        announcement_success2.Announcement_End_Date__c = today.addDays(3);
        announcement_success2.Announcement_Start_Date__c = today;
        announcement_success2.Brand__c = 'Speedo';
        testAnnouncements.add(announcement_success2);
        //insert announcement_success2;

        Brand_Bot_Announcement__c announcement_failure = new Brand_Bot_Announcement__c();
        announcement_failure.Announcement__c = 'This is a test announcement, set in the relative past';
        announcement_failure.Announcement_End_Date__c = today.addDays(8);
        announcement_failure.Announcement_Start_Date__c = today.addDays(5);
        announcement_failure.Brand__c = 'IZOD';
        testAnnouncements.add(announcement_failure);
        //insert announcement_failure;

        insert testAnnouncements;
        
    }

    @IsTest
    public static void testAnnouncement_success_ONE_DAY() {
        NF_GetBrandBotAnnouncement.Input testInput = new NF_GetBrandBotAnnouncement.Input();
        testInput.Brand_API_Name = 'Calvin Klein';
        List<NF_GetBrandBotAnnouncement.Input> testInputs = new List<NF_GetBrandBotAnnouncement.Input>{testInput};

        

        List<NF_GetBrandBotAnnouncement.Output> testOutputs = NF_GetBrandBotAnnouncement.getAnnouncement(testInputs);
        System.assert(testOutputs[0].announcementFound);
        System.assert(testOutputs[0].announcement == 'This is a test announcement');
    }
    @IsTest
    public static void testAnnouncement_success_RANGE_OF_DAYS() {
        NF_GetBrandBotAnnouncement.Input testInput = new NF_GetBrandBotAnnouncement.Input();
        testInput.Brand_API_Name = 'Speedo';
        List<NF_GetBrandBotAnnouncement.Input> testInputs = new List<NF_GetBrandBotAnnouncement.Input>{testInput};

        

        List<NF_GetBrandBotAnnouncement.Output> testOutputs = NF_GetBrandBotAnnouncement.getAnnouncement(testInputs);
        System.assert(testOutputs[0].announcementFound);
        System.assert(testOutputs[0].announcement == 'This is a test announcement, running over 3 days and overlapping today');
    }
    @IsTest
    public static void testAnnouncement_failure() {
        NF_GetBrandBotAnnouncement.Input testInput = new NF_GetBrandBotAnnouncement.Input();
        testInput.Brand_API_Name = 'IZOD';
        List<NF_GetBrandBotAnnouncement.Input> testInputs = new List<NF_GetBrandBotAnnouncement.Input>{testInput};

        

        List<NF_GetBrandBotAnnouncement.Output> testOutputs = NF_GetBrandBotAnnouncement.getAnnouncement(testInputs);
        System.assert(!testOutputs[0].announcementFound);
        System.assert(String.isBlank(testOutputs[0].announcement));
    }
}