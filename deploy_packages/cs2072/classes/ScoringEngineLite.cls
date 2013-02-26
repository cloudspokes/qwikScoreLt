/***************************************************************************
 Name : ScoringEngine
 Created By : Kyle Bowerman (kbowerman@appirio.com)
    modified from Jeff Douglas' cloudspokes class ScoringEngine
 Created Date :6/28/2012
 Description : Performs total score calculation
 https://docs.google.com/a/appirio.com/document/d/1FsFAD-oJ-oW6xxtH7Au-ekfmvAyi8jWuI55a89KmhXQ/edit
 for more info. Test class is Test_ScorecardEngine. 
 Appirio Inc all rights reserved        
***************************************************************************/

public with sharing class ScoringEngineLite {

 /**
  * Grade an individual scorecard. Never in bulk.
  */
  public static void gradeScorecard(Id scorecardId) {
   
   // QwikScore_Scorecard__c sc = [select Id, Reviewer__r.name, username__c, challenge_participant__r.challenge__c from QwikScore_Scorecard__c where id = :scorecardId];
     QwikScore_Scorecard__c sc = [select Id  from QwikScore_Scorecard__c where id = :scorecardId];
   
   
    // add the info to chatter
    //Utils.addChallengeChatterTextPost(sc.challenge_participant__r.challenge__c, 'Grading scorecard for '+sc.username__c);
   
      try {
     
      //To grade a score card, we need to find all answers associated with it, take their weighted scores and sum them.
      //then multiple that total by the group weight.
      decimal totalWeightedScore = 0.0;
      decimal maxScore = 0.0;
     
      if(maxScore == null)
        maxScore = 0; 
     
      //ok now run an aggregate query that sums all the weighted question answers, but breaks them
      //down by the group so we can multile each total by it's group weight. 
      AggregateResult[] answers = [ select SUM(Weighted_Score__c)totalScore, Question__r.QwikScore_Question_Group__c,
        max(Question__r.QwikScore_Question_Group__r.Group_Weight__c)groupWeight
        from QwikScore_Question_Answer__c
        where IsAnswered__c = 1 and
        Question__r.Question_Type__c = 'Numeric' and
        QwikScore_Scorecard__c = :scorecardId
        Group by ROLLUP(Question__r.QwikScore_Question_Group__c)];
        System.Debug('ktb answers Size: '+ answers.Size());
     
     
      //loop over the groups. There is 1 row for each group (+1 for a grand total row that we ignore)             
      for(AggregateResult ar: answers) {
        //An aggreate query contains a summary row at the end with the totals. Since we don't want to include
        //that in our math, add this if statment to exclude it, since it doesn't have a question group.
        if(ar.get('QwikScore_Question_Group__c') != null) {
  
          string questionGroup = (string) ar.get('QwikScore_Question_Group__c');
  
          decimal thisGroupWeight = (decimal)ar.get('groupWeight') / 100;
          decimal thisWeightedScore = (decimal)ar.get('totalScore');
          decimal thisWeightedTotal = (thisWeightedScore * thisGroupWeight);
         
          totalWeightedScore += thisWeightedTotal;
 
        }                               
      }
     
      totalWeightedScore = (totalWeightedScore)*100;
     
      //update the existing scorecard object with the new total weight and set the
      //scored checkmark to true so the user cannot modify their answers any more.
      QwikScore_Scorecard__c thisScoreCard = [select id, createdbyid from QwikScore_Scorecard__c where id = :scorecardId];
      thisScoreCard.Final_Score__c =  totalWeightedScore;
      thisScoreCard.Scored__c = true;
      System.Debug('ktb TotalWeigtedScore: '+ totalWeightedScore);
       System.Debug('ktb scorecardId:'+ scorecardId);
      
      update thisScoreCard;
           
    } catch(Exception e) {
     // Logger.log(Logger.FATAL, 'ScoringEngine', 'Error scoring scorecard '+ scorecardId + '. Error: '+e.getMessage());
     System.Debug('Fatal ScoringEngine Error scoring scorecard '+ scorecardId + '. Error: '+e.getMessage());
    } 
    } 
   
  }