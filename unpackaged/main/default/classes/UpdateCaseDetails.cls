public without sharing class UpdateCaseDetails {
  @InvocableMethod(label='Update Case' description='.' category='Case')
  public static void getCaseId(List<ID> caseId) {
      List<Group> listOfQueues=[select Id from Group where Type = 'Queue' and name = 'RTR Request'];
      Case cse = new Case();
      cse.Id = caseId[0];
      cse.OwnerId = listOfQueues[0].Id;
      update cse;
  
  }
}