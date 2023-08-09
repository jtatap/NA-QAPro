/**
 * @File Name          : NF_DynamicFollowUpOption.cls
 * @Description        : This class is used to generate quick reply buttons based on the carousel (product detail, rma or . case details)
 * @Author             : Manishi Kalra
 * @Created By         : NeuraFlash, LLC
**/
public class NF_DynamicFollowUpOption {
    /*
    * method name: getdynamicFollowUpOptions
    * description: this method will form the dynamic QR button.
    * input : dialog name
    * output: list of list of string (Yes, No, Find a different product)
    */
    @InvocableMethod(label='Neuraflash - Get Follow Up Options')
    public static List<List<String>> getdynamicFollowUpOptions(List<String> dialogName) {
        List<String> stringList = new List<String>();
        List<List<String>> finalStringList = new List<List<String>>();
        String QR1 = SYSTEM.LABEL.Yes;
        String QR2 = SYSTEM.LABEL.No;
        String QR3;

        if(!dialogName.isEmpty() && String.isNotBlank(dialogName[0])) {
            if(dialogName[0] == SYSTEM.LABEL.Product_Details) {
                QR3 = SYSTEM.LABEL.Find_a_different_product;
            }
            if(dialogName[0] == SYSTEM.LABEL.Case_Details) {
                QR3 = SYSTEM.LABEL.Find_a_different_case;
            }
            if(dialogName[0] == SYSTEM.LABEL.RMA_Details) {
                QR3 = SYSTEM.LABEL.Find_a_different_RMA;
            }
        }
        stringList.add(QR1);
        stringList.add(QR2);
        if(String.isNotBlank(QR3)) {
            stringList.add(QR3);
        }
        finalStringList.add(stringList);
        return finalStringList;
    }

}