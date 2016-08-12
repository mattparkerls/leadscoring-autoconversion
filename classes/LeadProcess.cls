public with sharing class LeadProcess {

    private static final String GREATER_THAN = '>';
    private static final String LESS_THAN = '<';
    private static final String GREATER_EQUALTO = '>=';
    private static final String LESS_EQUALTO = '<=';
    private static final String EQUALS = '=';
    private static final String NOTEQUALS = '!=';
    private static final String CONTAINS = '{}';
    private static final String NOTCONTAINS = '!{}';
    private static final String ADD = 'Add';
    private static final String REPLACE = 'Set';
    private static final String SUBTRACT = 'Subtract';
    private static String scoreField = (LeadProcessSetting__c.getInstance('ScoreField').Value__c == null) ? 'Score__c' : LeadProcessSetting__c.getInstance('ScoreField').Value__c;
    private static Decimal MAX_SCORE = (Decimal.valueOf(LeadProcessSetting__c.getInstance('MaxScore').Value__c) == null) ? 100 : Decimal.valueOf(LeadProcessSetting__c.getInstance('MaxScore').Value__c);
    private static Decimal CONVERT_SCORE = (Decimal.valueOf(LeadProcessSetting__c.getInstance('ConvertScore').Value__c) == null) ? 85 : Decimal.valueOf(LeadProcessSetting__c.getInstance('ConvertScore').Value__c);
    public static Integer loopCount = 0;

    public LeadProcess() {}


    /**
    * @author: Riitiir, LLC
    * @desc: Handles Lead scoring according to active ScoreRule__c records
    * @param: Trigger.newMap
    * @param: Trigger.oldMap
    * @return: void
    */
    public void doScoring(map<Id,Lead> newMap, map<Id,Lead> oldMap){

    List<Lead> leads = new List<Lead>();
    List<String> fields = new List<String>(Lead.SObjectType.getDescribe().fields.getMap().keySet());
    List<String> ruleFields = new List<String>(ScoreRule__c.SObjectType.getDescribe().fields.getMap().keySet());
    Set<Id> keyset = newMap.keyset();

    String ruleQuery = ''
        + ' select ' + String.join(ruleFields, ',')
        + ' from ScoreRule__c'
        + ' where isActive__c = true ORDER BY Order__c DESC';

    List<ScoreRule__c> rules = database.query(ruleQuery);

    String soql = ''
        + ' select ' + String.join(fields, ',')
        + ' from Lead'
        + ' where Id IN :keyset';

    for(Lead l : database.query(soql)){
      //resetting score to 0
      l.put(scoreField,0);
      //loop over all the settings
      for(ScoreRule__c rule : rules){
        //if rule is active
        if(rule.isActive__c) {
          //get type for Lead fields 
          Schema.DescribeFieldResult fieldType = Lead.SObjectType.getDescribe().fields.getMap().get(rule.FieldName__c).getDescribe();
            //If the field is a Number
            if(fieldType.getType() == Schema.DisplayType.Double || fieldType.getType() == Schema.DisplayType.Integer){
              //if it's not a range
              if(rule.Operator__c != 'range'){ 
                if(rule.Operator__c == GREATER_THAN) {             
                    if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) > rule.FieldValueNumber__c){ 
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                    } 
                }
                if(rule.Operator__c == LESS_THAN) {             
                    if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) < rule.FieldValueNumber__c){ 
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                    } 
                }
                if(rule.Operator__c == GREATER_EQUALTO) {             
                    if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) >= rule.FieldValueNumber__c){ 
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                    } 
                }
                if(rule.Operator__c == LESS_EQUALTO) {             
                    if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) <= rule.FieldValueNumber__c){ 
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                    } 
                }
                if(rule.Operator__c == EQUALS) {             
                    if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) == rule.FieldValueNumber__c){ 
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                    } 
                }
                if(rule.Operator__c == NOTEQUALS) {             
                    if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) != rule.FieldValueNumber__c){ 
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                    } 
                }
              }
              //else the number field IS a range 
              else {
                if(Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) >= rule.RangeLow__c 
                    && Integer.valueOf(newMap.get(l.id).get(rule.FieldName__c)) <= rule.RangeHigh__c ){
                      l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                }
              }
            }
          //If the field is a Checkbox
          else if(fieldType.getType() == Schema.DisplayType.Boolean) { 
            if(newMap.get(l.id).get(rule.FieldName__c) == true){
              l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
            }
            
          } 
          //If the field is a Picklist
          else if(fieldType.getType() == Schema.DisplayType.Picklist) {
            if(rule.Operator__c == EQUALS){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(String.valueOf(newMap.get(l.id).get(rule.FieldName__c)).contains(rule.FieldValueString__c)){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
            if(rule.Operator__c == NOTEQUALS){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(!String.valueOf(newMap.get(l.id).get(rule.FieldName__c)).contains(rule.FieldValueString__c)){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
          }
          //If the field is a String
        else if(fieldType.getType() == Schema.DisplayType.Email
                    || fieldType.getType() == Schema.DisplayType.URL
                    || fieldType.getType() == Schema.DisplayType.String ) {
            if(rule.Operator__c == EQUALS){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(String.valueOf(newMap.get(l.id).get(rule.FieldName__c)).toLowerCase() == (rule.FieldValueString__c.toLowerCase())){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
            if(rule.Operator__c == NOTEQUALS){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(String.valueOf(newMap.get(l.id).get(rule.FieldName__c)).toLowerCase() != (rule.FieldValueString__c.toLowerCase())){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
            if(rule.Operator__c == CONTAINS){
              if(newMap.get(l.id).get(rule.FieldName__c) != null){
                if(String.valueOf(newMap.get(l.id).get(rule.FieldName__c)).toLowerCase().deleteWhiteSpace().contains(rule.FieldValueString__c.toLowerCase().deleteWhiteSpace())){
                  l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                }
              }
            }
            if(rule.Operator__c == NOTCONTAINS){
              if(newMap.get(l.id).get(rule.FieldName__c) != null){
                if(!String.valueOf(newMap.get(l.id).get(rule.FieldName__c)).toLowerCase().deleteWhiteSpace().contains(rule.FieldValueString__c.toLowerCase().deleteWhiteSpace())){
                  l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                }
              }
            }
        }
          //If the field is a Date
        else if(fieldType.getType() == Schema.DisplayType.Date || fieldType.getType() == Schema.DisplayType.DateTime) {
            if(rule.Operator__c == GREATER_THAN){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(Date.valueOf(newMap.get(l.id).get(rule.FieldName__c)) > rule.FieldValueDate__c){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
            if(rule.Operator__c == LESS_THAN){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(Date.valueOf(newMap.get(l.id).get(rule.FieldName__c)) < rule.FieldValueDate__c){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
            if(rule.Operator__c == GREATER_EQUALTO){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(Date.valueOf(newMap.get(l.id).get(rule.FieldName__c)) >= rule.FieldValueDate__c){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
            if(rule.Operator__c == LESS_EQUALTO){
                if(newMap.get(l.id).get(rule.FieldName__c) != null){
                  if(Date.valueOf(newMap.get(l.id).get(rule.FieldName__c)) <= rule.FieldValueDate__c){
                    l.put(scoreField,newScore(l,rule.ScoreType__c,rule.ScoreValue__c));
                  }
                }
            }
          }
        }
      }
      //only add Lead to update if the score needs to be changed
      if(l.get(scoreField) != oldMap.get(l.id).get(scoreField)){ 
        //if score is over 100, just cap it
        if(Integer.valueOf(l.get(scoreField)) > MAX_SCORE){
          l.put(scoreField,MAX_SCORE);
        }
        leads.add(l);
      }

    }

    if(!leads.isEmpty()){
        loopCount += 1;
        if(loopCount <= 1){
            update leads;
        }
    }

  }

    /**
    * @author Riitiir, LLC
    * @desc Calculates a Lead score based on the score type
    * @param: Lead l
    * @param: String scoreType
    * @param: Decimal scoreValue
    */
    private Decimal newScore (Lead l, String scoreType, Decimal scoreValue) {
      Decimal score;
      if(scoreType == ADD){
        score = Integer.valueOf(l.get(scoreField)) + scoreValue;
      } else if (scoreType == REPLACE){
        score = scoreValue;
      } else if (scoreType == SUBTRACT){
        score = Integer.valueOf(l.get(scoreField)) - scoreValue;
      }
      return score;
    }

    /**
    * @author: Riitiir, LLC
    * @desc: Handles Lead auto assignments and conversion
    * @param: Trigger.newMap
    * @param: Trigger.oldMap
    * @return: void
    */
    public void doAutoConversion(map<Id,Lead> newMap){

        list<Lead> leadsToAssign = new list<Lead>();
        map<String,String> emailToAccountIdMap = new map<String,String>();
        map<String,String> accountOwnerMap = new map<String,String>();
        Set<Id> leadDomains = new Set<Id>();
        Set<Id> leadsWithEmails = new Set<Id>();


        for(Lead l : [SELECT Id, Email, Score__c FROM Lead WHERE Id IN :newMap.keyset() AND isConverted = false]){
            //only add lead email domains that qualify for auto conversion
            if(l.Score__c >= CONVERT_SCORE){
                if(l.Email != null){
                  leadDomains.add(l.Email.split('@').get(1)); //strip the email domain
                  leadsWithEmails.add(l.id);
                }
            } else {
                continue;
            }
        }
        // Now search the database looking for Contacts with matching email domains
        for(Contact[] contacts:[SELECT Id, Email_Domain__c, accountid, account.ownerid FROM Contact WHERE Email_Domain__c IN :leadDomains]) {
           for(Contact c:contacts) {
              if(c.Email != null) {
                 //strip the email domain into maps
                  emailToAccountIdMap.put(c.Email_Domain__c,c.accountId);
                  accountOwnerMap.put(c.Email_Domain__c,c.account.ownerid);
             }

            }
        } 


        for(Lead l : [SELECT Id, Email, Score__c FROM Lead WHERE Id IN :leadsWithEmails]){
          String leadDomain = l.Email.split('@').get(1);
          //if we don't have a match, add to Leads to Assign 
          if(emailToAccountIdMap.get(leadDomain) == null){
           l.auto_convert__c = true; //set auto convert flag to true
           leadsToAssign.add(l);
          } 
          //else if the lead domain matches with an existing Contact THEN convert and attach to the Contact's parent Account
          else if(emailToAccountIdMap.get(leadDomain) != null){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            lc.setAccountId(emailToAccountIdMap.get(leadDomain));
            lc.setOwnerId(accountOwnerMap.get(leadDomain));
            Database.LeadConvertResult lcr = Database.convertLead(lc);
          }
        }
        //lastly if we don't have an account to attach to, run assignment rules and reassign the lead - it will be converted via process builder later
        if(!leadsToAssign.isEmpty()){
            loopCount += 1;
            if(loopCount <= 3){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                Database.SaveResult[] lsr = Database.update(leadsToAssign, dmo);
            }
        }

    }

    /**
    * @author: Riitiir, LLC
    * @desc: Converts leads from Process Builder - that were not already converted via doAutoConversion()
    * @param: List<ID> 
    * @return: void
    */
    @InvocableMethod(label='Convert Leads' description='Converts leads for autoconversion')
    public static void convertLeadsByProcess(list<ID> leadIds){

        set<String> leadDomains = new set<String>();
        Set<Id> leadsWithEmails = new Set<Id>();
        map<String,String> emailToAccountIdMap = new map<String,String>();
        map<String,String> accountOwnerMap = new map<String,String>();

        for(Lead l : [SELECT Id, Email, Score__c FROM Lead WHERE Id IN :leadIds AND isConverted = false]){
            if(l.Email != null){
                  leadDomains.add(l.Email.split('@').get(1)); //strip the email domain
                  leadsWithEmails.add(l.id);
            } else {
                continue;
            }
        }
        
        // Now search the database looking for Contacts with matching email domains
        for(Contact[] contacts:[SELECT Id, Email_Domain__c, accountid, account.ownerid FROM Contact WHERE Email_Domain__c IN :leadDomains]) {
           for(Contact c:contacts) {
              if(c.Email_Domain__c != null) {
                 //strip the email domain into maps
                  emailToAccountIdMap.put(c.Email_Domain__c,c.accountId);
             }
            }
        } 

        //convert each lead to a new Account or attach to existing Account
        for(Lead l : [SELECT Id,Email FROM Lead WHERE Id IN :leadsWithEmails]){ 
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true);
            if(emailToAccountIdMap.get(l.Email.split('@').get(1)) != null){
              lc.setAccountId(emailToAccountIdMap.get(l.Email.split('@').get(1)));
            }
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
    }




}