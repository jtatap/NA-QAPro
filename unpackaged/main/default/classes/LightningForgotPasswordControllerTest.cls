@IsTest(SeeAllData = true)
public with sharing class LightningForgotPasswordControllerTest {

 /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
 @IsTest
 static void testLightningForgotPasswordControllerInvalidUserName() {
  Test.startTest();
  System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
  System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
     Test.stopTest();
 }

 /* Verifies that null checkEmailRef url throws proper exception. */
 @IsTest
 static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
     Test.startTest();
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
     Test.stopTest();
 }

 /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
 @IsTest
 static void LightningForgotPasswordControllerInstantiation() {
     Test.startTest();
  LightningForgotPasswordController controller = new LightningForgotPasswordController();
  System.assertNotEquals(controller, null);
     Test.stopTest();
 }
    
    @IsTest
    static void setExpId(){
        Test.startTest();
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        String abc = LightningForgotPasswordController.setExperienceId('');
        Test.stopTest();
    }
}