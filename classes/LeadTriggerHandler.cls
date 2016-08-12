public class LeadTriggerHandler {
 
	public static void afterUpdate(map<Id,Lead> newmap , map<Id,Lead> oldmap){
		LeadProcess process = new LeadProcess();
		process.doScoring(newmap,oldmap);
		process.doAutoConversion(newmap);
	}
  
}