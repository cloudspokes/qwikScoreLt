/*
 * Controller for the mobile-optimized survey page (SurveyMobil.page)
 *
 * 07/10/2012  Cory McIlroy added header to this class.  also added call to ScoringEngineLite after save.  other minor changes
 * 02/26/2013 Moved from SurveyMobileControllerTalesforce to SurveyMobileControllerT
 */
public with sharing class SurveyMobileController {
    
     /* Getter method for attachment URL */
    public string AttachementUrl{
        get{
            return getSfInstance()+'/apex/AttachmentUpload?aid='+ApexPages.currentPage().getParameters().get('aid')+'&stid='+ApexPages.currentPage().getParameters().get('stid');
        }
    }
    
    //constructor
    public SurveyMobileController(){
    	//constructor element.
    }
    /* Get Salesforce Instance */
    public String getSfInstance()
    {
          return URL.getSalesforceBaseUrl().toExternalForm();
    }
       
    /* Old code from Cory McIlroy starts here */
    
    public static Account surveyAccount;
    public static QwikScore__c scoreCardType;

   
    @RemoteAction 
        public static QwikScore_Scorecard__c saveScoreCard(String jsonString){
            List<QwikScore_Question_Answer__c> answerList = (List<QwikScore_Question_Answer__c>)JSON.deserialize(jsonString, List<QwikScore_Question_Answer__c>.class);
            QwikScore_Scorecard__c scoreCard = new QwikScore_Scorecard__c();
            if (answerList.size() > 0){
                scoreCard = answerList[0].QwikScore_Scorecard__r;
                insert scoreCard;
                for(QwikScore_Question_Answer__c answer: answerList){
                    answer.QwikScore_Scorecard__r = null;
                    answer.QwikScore_Scorecard__c = scoreCard.id;                    
                    answer.Answer_Unique_Id__c = String.valueOf(Math.random());
                }
                insert answerList;

                //Call the scoring package
                ScoringEngineLite.gradeScorecard(scoreCard.Id);  //ktb 7.2

                surveyAccount = getAccountInfo(scoreCard.Survey_For__c);
                scoreCardType = getScoreCardType(scoreCard.QwikScore_Survey__c);

                    
                if (surveyAccount != null && scoreCardType != null) {
                 /* cleaned up a lot of unused code from here */
                        List<QwikScore_Scorecard__c> finishedScoreCards = 
                            [select Final_Score__c from QwikScore_Scorecard__c 
                            where QwikScore_Survey__c = :scoreCardType.Id 
                            and Survey_For__c = :surveyAccount.Id 
                            order by createdDate desc limit 10];
                        Decimal totalScore = 0.0;
                        for(QwikScore_Scorecard__c sCard:finishedScoreCards){
                            totalScore += sCard.Final_Score__c;
                      // once done calculating total score, update the survey account
                        update surveyAccount;
                    }
                }
                else {
                    //TODO
                    System.debug('survey and/or scorecardtype should not be null');
                }
            }
            
            //upload image as attachment.            
            return scoreCard;
        }

    //Method to create a list of question answers for the given score card type
    @RemoteAction 
        public static List<QwikScore_Question_Answer__c> questionAnswersJS(String accountId, String scoreCardTypeId){
            List<QwikScore_Question_Answer__c> questionAnswers = new List<QwikScore_Question_Answer__c>();
            QwikScore_Scorecard__c qs = new QwikScore_Scorecard__c();
            surveyAccount = getAccountInfo(accountId);
            scoreCardType = getScoreCardType(scoreCardTypeId);
            if (surveyAccount == null || scoreCardType == null) {
                return null;
            }
                    if(!checkSurveyAccessibility(scoreCardType)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry! '+scoreCardType.Name+' survey is not available'));
                        return null;
                    }
            qs.Survey_For__c = surveyAccount.Id;
            qs.Survey_For__r = surveyAccount;
            qs.QwikScore_Survey__c = scoreCardType.Id;
            qs.QwikScore_Survey__r = scoreCardType;
            //Geting the ScoreCard Type record with question Groups
            List<QwikScore_Question_Group__c> listOfGroups = [SELECT Id FROM QwikScore_Question_Group__c WHERE QwikScore_Survey__c = :scoreCardTypeId];
            //Creating a map of question group and question answer record
            QwikScore_Question_Answer__c qAnswer = null; 
            for(QwikScore_Question__c question:[SELECT Id,Name,QwikScore_Question_Group__c, 
                    QwikScore_Question_Group__r.Sequence_Number__c,
                    QwikScore_Question_Group__r.Group_Weight__c,
                    QwikScore_Question_Group__r.Name,
                    QwikScore_Question_Group__r.QwikScore_Survey__c,
                    QwikScore_Question_Group__r.QwikScore_Survey__r.Name,
                    Sequence_Number__c,
                    Question_Text__c,
                    Maximum_Value__c,
                    Minimum_Value__c,
                    Question_Type__c,
                    IsHidden__c,unhideIfQuestion__c,unhideQuestionValue__c,
                    Question_Weight__c,
                    State__c,
                    Area__c
                    FROM QwikScore_Question__c 
                    WHERE QwikScore_Question_Group__c 
                    IN : listOfGroups
                    ORDER BY QwikScore_Question_Group__r.Sequence_Number__c, Sequence_Number__c]){
                qAnswer = new QwikScore_Question_Answer__c();
                qAnswer.Question__c = question.Id;
                qAnswer.Question__r = question;
                qAnswer.Answer_Text__c = null;
                qAnswer.comments__c= null;
                qAnswer.QwikScore_Scorecard__r  = qs;
                questionAnswers.add(qAnswer);
            }
            //put here for testing, commenting out - system.assert(false, questionAnswers);
            System.debug(questionAnswers);
            return questionAnswers;
        } 
    
    public static Account getAccountInfo(String accountId){
        List<Account> accounts = [SELECT Id,Name,BillingStreet, BillingState, BillingPostalCode,
            BillingCountry, BillingCity from Account where Id = :accountId];
        if (accounts != null && accounts.size()>0) {
            return accounts[0];
        }
        else {
            return null;
        }
    }
    public static QwikScore__c getScoreCardType(String scoreCardTypeId){
        List<QwikScore__c> scoreCardTypes = [SELECT Id,Name FROM QwikScore__c WHERE Id = :scoreCardTypeId];
        if (scoreCardTypes != null && scoreCardTypes.size()>0) {
            return scoreCardTypes[0];
        }
        else {
            return null;
        }
    }
        public static Boolean checkSurveyAccessibility(QwikScore__c surveyType){
        if(UserInfo.getName() == 'surveys Site Guest User' && surveyType.Name != 'Customer Satisfaction'){
            return false;
        }
        else{
            return true;
        }
    }    
}