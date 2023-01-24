@isTest
public class R2RProcessDataTest {

    public TestMethod static void processdata(){
        R2RProcessData r2r = new R2RProcessData();
        r2r.rectifiedData = '{"newEmail":"","newFirstName":"testsek","newLastName":"testbar","newAddress":"test 234","newUnit":"111","newCountry":"United States of America","newState":"Maryland","newZipCode":"20874","newPhone":"1234561234","newGender":"Male","newMonth":"5","newDate":"17","add":{"changedAddress":"test 234","changedUnit":"111","changedCountry":"United States of America","changedState":"Maryland","changedZipCode":"20874","changedPhone":"1234561234","changedGender":"Male","changedMonth":"5","changedDate":"17"}}';
        r2r.getProcessData();
    }
}