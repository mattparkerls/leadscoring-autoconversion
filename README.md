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
* Lead is matched with Existing Accounts
* If Lead already exists as an Account, Lead is converted and attached as a new Contact
* If Lead does not exist as an Account, Lead is reassigned according to active Assingment Rules
* After Assignment Rules run, Lead is converted into a new Account 

Autoconversion should convert all Leads that meet the predefined score.  The goal is to convert highly-ranked Leads without creating duplicates. And assign these Leads to the proper owner.  

## Usage
### How to implement

The core components are:
* LeadProcess.cls
* Autoconvert.flow
* ScoreRule__c.object
* LeadProcessSetting.object

You must first configure these Custom Settings:

![alt text](https://github.com/mattparkerls/leadscoring-autoconversion/blob/master/images/settinglist.png)

The values can be whatever you want, but Convert Score defaults to 85, MaxScore defaults to 100, and the ScoreField defaults to Lead.Score__c.

Once the settings are configured you need to create some Score Rules

Finally, depending on your Trigger Handler Framework of choice, you can call either Lead Scoring & Autoconversion together or separately.  Simply instantiate the LeadProcess.cls class and call:
```java
LeadProcess process = new LeadProcess();
process.doScoring(newLeadmap,oldLeadmap);
process.doRouting(newLeadmap,oldLeadmap);
```
Or from your Lead Trigger Handler:
```java
public class LeadTriggerHandler {

public static void afterUpdate(map<Id,Lead> newmap , map<Id,Lead> oldmap){
    LeadProcess process = new LeadProcess();
    process.doScoring(newmap,oldmap);
    process.doRouting(newmap,oldmap);
}

}
```

Does not support: Before Insert, Before Update, After Delete
