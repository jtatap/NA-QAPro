/**
 * Created by NeuraFlash LLC on 10/23/19.
 */

public with sharing class NF_SetString {

    public class Input{
        @InvocableVariable(required=true)
        public String inputString;
    }
    public class Output{
        @InvocableVariable(required=false)
        public String outputString;
    }
    @InvocableMethod(label='Neuraflash - Set String w/ Yes/No handling')
    public static List<Output> setString(List<Input> input){

        List<Output> outputs = new List<Output>();
        Output output = new Output();

        String entered = input[0].inputString;
        if(entered.equalsIgnoreCase(SYSTEM.LABEL.YUP) || entered.equalsIgnoreCase(SYSTEM.LABEL.YES1) || entered.equalsIgnoreCase(SYSTEM.LABEL.YA) || entered.equalsIgnoreCase(SYSTEM.LABEL.YEAH) || entered.equalsIgnoreCase(SYSTEM.LABEL.YEP))
        {
            output.outputString = SYSTEM.LABEL.YES1;
        }
        else if(entered.equalsIgnoreCase(SYSTEM.LABEL.NO1) || entered.equalsIgnoreCase(SYSTEM.LABEL.NOPE) || entered.equalsIgnoreCase(SYSTEM.LABEL.NAH)) {
            output.outputString = SYSTEM.LABEL.NO1;
        }
        else {
            output.outputString = input[0].inputString;
        }
        outputs.add(output);
        return outputs;
    }
}