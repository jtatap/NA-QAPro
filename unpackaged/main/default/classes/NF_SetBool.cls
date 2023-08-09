/**
 * Created by NeuraFlash LLC on 10/21/19.
 */

global without sharing class NF_SetBool {
    @InvocableMethod(label='Neuraflash - Set Boolean')
    global static List<Boolean> setBool(List<String> input) {
        String val = input.get(0);
        if(val.toLowerCase() == SYSTEM.LABEL.true){
            return new List<Boolean>{true};
        }
        return new List<Boolean>{false};
    }
}