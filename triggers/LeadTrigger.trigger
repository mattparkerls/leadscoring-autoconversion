trigger LeadTrigger on Lead (after insert,after update) {

	if(Trigger.isUpdate && Trigger.isAfter){
		LeadTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap);
	}
	if(Trigger.isInsert && Trigger.isAfter){
		LeadTriggerHandler.afterInsert(trigger.newMap);
	}
	
}