public with sharing class SurveyResultsController {
    public Account surveyAccount{get;set;}
    public User surveyUser{get;set;}
    public QwikScore__c scoreCardType{get;set;}
    public QwikScore_Scorecard__c scoreCard{get;set;}
    public List<QwikScore_Question_Group__c> questionGroups{get;set;}
    public map<Id,List<QwikScore_Question_Answer__c>> questionAnswerMap{get;set;}
    public Boolean isValid{get;set;}
    //Constructor
    public SurveyResultsController(){
        questionAnswerMap = new map<Id,List<QwikScore_Question_Answer__c>>();
        questionGroups = new List<QwikScore_Question_Group__c>();
        isValid=false;
        String scoreCardId = ApexPages.currentPage().getParameters().get('score_card_id');
        fillScoreCard(scoreCardId);
        fillScoreCardType();
    }
    //Filling Score card object
    public void fillScoreCard(String scoreCardId){
        scoreCard = [SELECT Id,Name,Survey_For__c,Survey_For__r.Name, 
        							 Total_Raw_Score__c, Final_Score__c,
                       CreatedBy.Name,CreatedDate,  QwikScore_Survey__c,QwikScore_Survey__r.Name 
                     FROM QwikScore_Scorecard__c 
                     WHERE Id = :scoreCardId];
    }
    
   
    //Filling ScoreCard Type object
    public void fillScoreCardType(){
        //Geting the ScoreCard Type record with question Groups
        scoreCardType = [SELECT Id,Name, 
                           (SELECT Id,Name 
                            FROM QwikScore_Question_Groups__r)
                         FROM QwikScore__c 
                         WHERE Id = :scoreCard.QwikScore_Survey__c];
        set<Id> qGroupIdSet = new set<Id>();
        questionGroups.addAll(scoreCardType.QwikScore_Question_Groups__r);
        for(QwikScore_Question_Group__c qGroup:scoreCardType.QwikScore_Question_Groups__r){
            qGroupIdSet.add(qGroup.Id);
        }
        //Creating a map of question group and question answer record
        for(QwikScore_Question_Answer__c questionAns:[SELECT Id,Name,Answer_Text__c,QuestionGroupId__c ,Question__r.Question_Text__c, 
                                                                                             Question__r.Maximum_Value__c,Question__r.Minimum_Value__c
                                                                                FROM QwikScore_Question_Answer__c 
                                                                                WHERE QwikScore_Scorecard__c 
                                                                                = : scoreCard.Id]){
            if(!questionAnswerMap.containsKey(questionAns.QuestionGroupId__c)){
                questionAnswerMap.put(questionAns.QuestionGroupId__c,new List<QwikScore_Question_Answer__c>());
            }
            questionAnswerMap.get(questionAns.QuestionGroupId__c).add(questionAns);
        }
    }
    
    
    public PageReference cancel(){
        return new PageReference('/'+scoreCard.Id);
    }
}