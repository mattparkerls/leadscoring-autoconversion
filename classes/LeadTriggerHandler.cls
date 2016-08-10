public class LeadTriggerHandler {
 
  public static void afterUpdate(map<Id,Lead> newmap , map<Id,Lead> oldmap){
      LeadProcess leadprocess = new LeadProcess();
      leadprocess.doScoring(newmap,oldmap);
      leadprocess.doRouting(newmap,oldmap);
  }
  
}