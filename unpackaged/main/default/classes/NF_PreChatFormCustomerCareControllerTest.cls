@isTest
public class NF_PreChatFormCustomerCareControllerTest {

     @isTest
    static void checkAgentAvailable()
    {
       String isAgentAvailable =  NF_PreChatFormCustomerCareController.checkAgentAvailable();
        System.assertEquals(isAgentAvailable, 'true');
    }
    
    @isTest
    static void getBrandTest(){
        String brand = NF_PreChatFormCustomerCareController.getBrand('https://help.usa.tommy.com/s/brand-form');
    	 System.assertEquals(brand, 'Tommy Hilfiger');
    }
}