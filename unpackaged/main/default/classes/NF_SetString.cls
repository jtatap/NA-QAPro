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
        if(entered.equalsIgnoreCase('YUP') || entered.equalsIgnoreCase('YES') || entered.equalsIgnoreCase('YA') || entered.equalsIgnoreCase('YEAH') || entered.equalsIgnoreCase('YEP'))
        {
            output.outputString = 'Yes';
        }
        else if(entered.equalsIgnoreCase('NO') || entered.equalsIgnoreCase('NOPE') || entered.equalsIgnoreCase('NAH')) {
            output.outputString = 'No';
        }
        else {
            output.outputString = input[0].inputString;
        }
        outputs.add(output);
        return outputs;
    }
}