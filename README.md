# Lead Scoring and Auto Conversion Utility
Configure scoring rules and auto-convert leads

This unmanaged package contains 2 parts:

1. Lead Scoring
2. Autoconversion 

## Lead Scoring
Do you handle complex Lead scoring logic inside of a Trigger or Class? If so, this repo is for you. 

Create "Score Rules" and configure complex scoring through point & click SFDC without any new code.  Filter text fields, picklists, date, numbers by the following operators:
* Equals/Not Equals
* Greater Than/Less Than
* Greater Than or Equal to/Less Than or Equal To
* Contains/Does Not Contain
* Ranges between 2 Numbers

#### Example Score Rules
![alt text](https://github.com/mattparkerls/leadscoring-autoconversion/blob/master/images/rulelistview.png)
#### Page Layout for Score Rule
![alt text](https://github.com/mattparkerls/leadscoring-autoconversion/blob/master/images/ruledetail.png)

## Autoconversion
The autoconversion process fires from a configurable "Convert Score":
![alt text](https://github.com/mattparkerls/leadscoring-autoconversion/blob/master/images/convertscore.png)

Once the Lead has a score of 85 (or otherwise) it will automatically convert.  
The conversion process follows these steps:

    1. Lead is matched with existing Contacts via Email_Domain__c
    2. If Lead matches with a Contact, Lead is converted and attached to the parent Account as a new Contact
    3. If Lead does not match, Lead is reassigned according to active Assingment Rules
    4. After Assignment Rules run, Lead is converted into a new Account 

Autoconversion should convert all Leads that meet the predefined score.  The goal is to convert highly-ranked Leads without creating duplicates. And assign these Leads to the proper owner.  

## How to implement

The core components are:
* LeadProcess.cls
* Autoconvert.flow
* ScoreRule__c.object
* LeadProcessSetting.object

LeadTrigger.trigger and LeadTriggerHandler.cls are included for example purposes only.

### 1. Install the ummanaged package:

### 2. Configure these Custom Settings:

![alt text](https://github.com/mattparkerls/leadscoring-autoconversion/blob/master/images/settinglist.png)

The values can be whatever you want, but Convert Score defaults to 85, MaxScore defaults to 100, and the ScoreField defaults to Lead.Score__c.

### 3. Once the settings are configured you need to create some Score Rules
![alt text](https://github.com/mattparkerls/leadscoring-autoconversion/blob/master/images/newrule.png)

### 4. Call LeadProcess.cls
Finally, depending on your Trigger Handler Framework of choice, you can call either Lead Scoring & Autoconversion together or separately.  Simply instantiate the LeadProcess.cls class and call:
```java
LeadProcess process = new LeadProcess();
process.doScoring(Trigger.newmap,Trigger.oldmap);
process.doAutoConversion(Trigger.newmap);
```
Or from your Lead Trigger Handler:
```java
public class LeadTriggerHandler {

public static void afterUpdate(map<Id,Lead> newmap , map<Id,Lead> oldmap){
    LeadProcess process = new LeadProcess();
    process.doScoring(newmap,oldmap);
    process.doAutoConversion(newmap);
}

}
```

NOTE Does not support these trigger operations yet: Before Insert, Before Update, After Delete
