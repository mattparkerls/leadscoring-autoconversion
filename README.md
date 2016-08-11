# leadscoring-autoconversion
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


## Usage
### How to implement
Depending on your Trigger Handler Framework of choice, you can call either Lead Scoring & Autoconversion together or separately.  Simply instantiate the LeadProcess.cls class and call:
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
