/*
 * Controller for the original Survey, probably deprecated in favor of the mobile one?
 */
public with sharing class SurveyController {
    public Account surveyAccount{get;set;}
    public User surveyUser{get;set;}
    public QwikScore__c scoreCardType{get;set;}
    public QwikScore_Scorecard__c scoreCard{get;set;}
    public List<QwikScore_Question_Group__c> questionGroups{get;set;}
    public map<Id,List<QwikScore_Question_Answer__c>> questionAnswerMap{get;set;}
    public Boolean isValid{get;set;}
        public map<Integer,List<SelectOption>> answerValues{get;set;}
    //Constructor
    public SurveyController(){
        isValid=false;
        String accountId = ApexPages.currentPage().getParameters().get('account_id');
        String userId = ApexPages.currentPage().getParameters().get('user_id');
        String scoreCardTypeId = ApexPages.currentPage().getParameters().get('scorecard_type_id');
        questionAnswerMap = new map<Id,List<QwikScore_Question_Answer__c>>();
        questionGroups = new List<QwikScore_Question_Group__c>();
        answerValues = new map<Integer,List<SelectOption>>(); 
        if(surveyAccount==null){
            if(accountId!=null){
                fillAccount(accountId);
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account Id is not available'));
            }
        }
        if(surveyUser==null){
            if(userId!=null){
                fillUser(userId);
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User Id is not available'));
            }
        }
        if(scoreCardType==null && (!ApexPages.hasMessages())){
            if(scoreCardTypeId!=null){
                fillScoreCardType(scoreCardTypeId);
                isValid = true;
                scoreCard = new QwikScore_Scorecard__c();
                scoreCard.Survey_For__c = surveyAccount.Id;
                scoreCard.QwikScore_Survey__c = scoreCardType.Id;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ScoreCard Type Id is not available'));
            }
            
        }
    }
    //Filling Account object 
    public void fillAccount(String accountId){
        surveyAccount = [SELECT Id,Name FROM Account WHERE Id = :accountId];
    }
    //Filling User object
    public void fillUser(String userId){
        surveyUser = [SELECT Id,Name FROM User WHERE Id = :userId];
        
    }
    //Filling ScoreCard Type object
    public void fillScoreCardType(String scoreCardTypeId){
        //Geting the ScoreCard Type record with question Groups
        scoreCardType = [SELECT Id,Name, 
                           (SELECT Id,Name 
                            FROM QwikScore_Question_Groups__r order by Sequence_Number__c)
                         FROM QwikScore__c 
                         WHERE Id = :scoreCardTypeId];
        set<Id> qGroupIdSet = new set<Id>();
        questionGroups.addAll(scoreCardType.QwikScore_Question_Groups__r);
        for(QwikScore_Question_Group__c qGroup:scoreCardType.QwikScore_Question_Groups__r){
            qGroupIdSet.add(qGroup.Id);
        }
        //Creating a map of question group and question answer record
        QwikScore_Question_Answer__c qAnswer = null; 
        for(QwikScore_Question__c question:[SELECT Id,Name,QwikScore_Question_Group__c,Question_Text__c, 
                                            	Question_Type__c,Maximum_Value__c,Minimum_Value__c
                                            FROM QwikScore_Question__c 
                                            WHERE QwikScore_Question_Group__c 
                                            IN : qGroupIdSet order by Sequence_Number__c]){
            if(!questionAnswerMap.containsKey(question.QwikScore_Question_Group__c)){
                questionAnswerMap.put(question.QwikScore_Question_Group__c,new List<QwikScore_Question_Answer__c>());
            }
            if(!answerValues.containsKey(Integer.valueOf(question.Maximum_Value__c))){
                fillAnswerValues(Integer.valueOf(question.Minimum_Value__c),Integer.valueOf(question.Maximum_Value__c));
            }
            qAnswer = new QwikScore_Question_Answer__c();
            qAnswer.Question__c = question.Id;
            qAnswer.Question__r = question;
//          qAnswer.QwikScore_Scorecard__c = scoreCard.Id;
            questionAnswerMap.get(question.QwikScore_Question_Group__c).add(qAnswer);
        }
    }
    public PageReference save(){
        //saving the score card first
        insert scoreCard;
        List<QwikScore_Question_Answer__c> toSaveList = new List<QwikScore_Question_Answer__c>();
        //creating a single list of question answers of different group
        for(QwikScore_Question_Group__c qGroup:scoreCardType.QwikScore_Question_Groups__r){
            toSaveList.addAll(questionAnswerMap.get(qGroup.Id));
        }
        for(QwikScore_Question_Answer__c qAnswer : toSaveList){
            qAnswer.QwikScore_Scorecard__c = scoreCard.Id;
            qAnswer.Answer_Unique_Id__c = String.valueOf(Math.random());
        }
        //saving the question answers
        if(toSaveList.size() > 0){
            insert toSaveList;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Survey is saved successfully'));
            ScoringEngineLite.gradeScorecard(scoreCard.Id);  //ktb 7.2
            System.Debug('ktb: scoreCardType.Name= '+ scoreCardType.Name);
            // check to see if this survey should update the last_inpection date may comment out if this type does not count
            /*if( scoreCardType.Name == 'Final Walkthrough Checklist' ){
               surveyAccount.Last_Inspection__c =  datetime.now(); 
               update surveyAccount;
               System.Debug('ktb: Last_Inspection__c to be set');
            }
            */
            // check to see if this survey should update the last_inpection date
            /*if( scoreCardType.Name == 'ROR' ){
               surveyAccount.Last_Inspection__c =  datetime.now(); 
               update surveyAccount;
               System.Debug('ktb: Last_Inspection__c to be set');
            }
            */
            // update Perf_Customer_Sat__c on account record
            //if ( scoreCardType.Name == 'Customer Satisfaction Survey') {
               List<QwikScore_Scorecard__c> finishedScoreCards = [select Final_Score__c from QwikScore_Scorecard__c where QwikScore_Survey__c = :scoreCardType.Id and Survey_For__c = :surveyAccount.Id order by createdDate desc limit 10];
               Decimal totalScore = 0.0;
               for(QwikScore_Scorecard__c sCard:finishedScoreCards){
               	totalScore += sCard.Final_Score__c;
              // }
               /*
               if(finishedScoreCards!=null && finishedScoreCards.size()>0){
               		surveyAccount.Perf_Customer_Sat__c = totalScore/finishedScoreCards.size();
               }*/
              update surveyAccount;
            }
            
        }
        return new PageReference('/'+scoreCard.Id);
    }
    public PageReference noSurvey(){
        return new PageReference('/'+surveyAccount.Id);
    }
    public PageReference cancel(){
        return new PageReference('/'+surveyAccount.Id);
    }
    public void fillAnswerValues(Integer minValue,Integer maxValue){
    answerValues.put(maxValue,new List<SelectOption>());                    
        for(Integer answerValue =minValue;answerValue<=maxValue;answerValue++){
        answerValues.get(maxValue).add(new SelectOption(String.valueOf(answerValue),String.valueOf(answerValue)));
    }
    }    
}