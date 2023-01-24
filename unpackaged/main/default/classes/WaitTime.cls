public class WaitTime {
    @InvocableMethod(Label='Wait for 10sec' Description='Waiting for 10sec')
	public static void wait() {
    Integer millisec = 10000;
    if(millisec == null || millisec < 0) {
      millisec = 0;
    }
      
    Long startTime = DateTime.now().getTime();
    Long finishTime = DateTime.now().getTime();
    while ((finishTime - startTime) < millisec) {
      //sleep for parameter x millisecs
      finishTime = DateTime.now().getTime();
    }
     System.debug('>>> Done from ' + startTime + ' to ' + finishTime);
  }
    
}