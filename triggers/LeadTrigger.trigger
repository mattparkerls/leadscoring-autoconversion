trigger LeadTrigger on Lead (after insert,after update) {

	if(Trigger.isAfter && Trigger.isUpdate){
	  LeadTriggerHandler.afterUpdate(trigger.newmap, trigger.oldmap);
	}
	
}