/** 
 * This class contains test methods for ManageRulesCriteria class
 */
@isTest
public class SureveyTest{ 
    
    public static testMethod void testMobileController(){
    	
    	//Creating scorecard type.    	
    	QwikScore__c scorecardType=new QwikScore__c();
    	scorecardType.Active__c=true;
    	scorecardType.Name='test_scorecard';
    	
    	//Creating an Account
    	Account ac=new Account();
    	ac.Name='test account';
    	
    	insert ac;
    	
    	//insert scorecard type.
    	insert scorecardType;
    	
    	List<QwikScore_Question_Group__c> groups=new List<QwikScore_Question_Group__c>();
    	
    	//Creating question group.
    	QwikScore_Question_Group__c group1=new QwikScore_Question_Group__c();
    	group1.Name='Group 1';
    	group1.QwikScore_Survey__c=scorecardType.Id;
    	group1.Group_Weight__c=10;
    	group1.Sequence_Number__c=1;
    	
    	QwikScore_Question_Group__c group2=new QwikScore_Question_Group__c();
    	group2.Name='Group 2';
    	group2.QwikScore_Survey__c=scorecardType.Id;
    	group2.Group_Weight__c=20;
    	group2.Sequence_Number__c=2;
    	
    	groups.add(group1);
    	groups.add(group2);
    	
    	insert groups;
    	
    	//Creating questions for groups.
    	List<QwikScore_Question__c> questions=new List<QwikScore_Question__c>();
    	
    	QwikScore_Question__c question1=new QwikScore_Question__c();    	
    	question1.Question_Text__c='What is the question?';
    	question1.QwikScore_Question_Group__c=group1.id;
    	question1.Maximum_Value__c=4;
    	question1.Minimum_Value__c=1;
    	question1.Question_Weight__c=20;
    	question1.Question_Type__c='Numeric';
    	
    	questions.add(question1); //add to list
    	
    	QwikScore_Question__c question2=new QwikScore_Question__c();    	
    	question2.Question_Text__c='What is the question?';
    	question2.QwikScore_Question_Group__c=group1.id;
    	question2.Maximum_Value__c=4;
    	question2.Minimum_Value__c=1;
    	question2.Question_Weight__c=0;
    	question2.Question_Type__c='Text';
    	
    	questions.add(question2); //add to list
    	
    	QwikScore_Question__c question3=new QwikScore_Question__c();    	
    	question3.Question_Text__c='What is the question?';
    	question3.QwikScore_Question_Group__c=group1.id;
    	question3.Maximum_Value__c=4;
    	question3.Minimum_Value__c=1;
    	question3.Question_Weight__c=0;
    	question3.Question_Type__c='True/False';
    	
    	questions.add(question3); //add to list
    	
    	
    	//For group two.
    	QwikScore_Question__c question4=new QwikScore_Question__c();    	
    	question4.Question_Text__c='What is the question?';
    	question4.QwikScore_Question_Group__c=group2.id;
    	question4.Maximum_Value__c=4;
    	question4.Minimum_Value__c=1;
    	question4.Question_Weight__c=20;
    	question4.Question_Type__c='Numeric';
    	
    	questions.add(question4); //add to list
    	
    	QwikScore_Question__c question5=new QwikScore_Question__c();    	
    	question5.Question_Text__c='What is the question?';
    	question5.QwikScore_Question_Group__c=group2.id;
    	question5.Maximum_Value__c=4;
    	question5.Minimum_Value__c=1;
    	question5.Question_Weight__c=0;
    	question5.Question_Type__c='Text';
    	
    	questions.add(question5); //add to list
    	
    	QwikScore_Question__c question6=new QwikScore_Question__c();    	
    	question6.Question_Text__c='What is the question?';
    	question6.QwikScore_Question_Group__c=group2.id;
    	question6.Maximum_Value__c=4;
    	question6.Minimum_Value__c=1;
    	question6.Question_Weight__c=0;
    	question6.Question_Type__c='True/False';
    	 
    	questions.add(question6); //add to list
    	
    	insert questions;
    	
    	SurveyMobileControllerTalesforce controller=new SurveyMobileControllerTalesforce();
    	//calling mobilesurevey constructor.
    	Pagereference page=new Pagereference('SurveyMobileTalesforce') ;
    	Test.setCurrentPageReference(page);
    	
    	// Add parameters to page URL
        ApexPages.currentPage().getParameters().put('aid', ac.Id);
        ApexPages.currentPage().getParameters().put('stid', scorecardType.Id);
        
        
    	List<QwikScore_Question_Answer__c> answerlist=SurveyMobileControllerTalesforce.questionAnswersJS(ac.Id,scorecardType.Id);
    	
    	//update each answer with comment and answer text
    	for(QwikScore_Question_Answer__c ans: answerlist){
    		ans.Answer_Text__c='2';
    		ans.comments__c='My test comments. Same for all';
    	}
    	
    	String str = JSON.serialize(answerlist);
    	
    	//Calling save scorecard.
    	SurveyMobileControllerTalesforce.saveScoreCard(str);
    	
    	
    	//Loading AttachmentUpload    	
    	
    	Pagereference page2=new Pagereference(controller.AttachementUrl) ;
    	Test.setCurrentPageReference(page2);
    	
    	// Add parameters to page URL
        ApexPages.currentPage().getParameters().put('aid', ac.Id);
        ApexPages.currentPage().getParameters().put('stid', scorecardType.Id);
        
        AttachmentUploadController attachmentController=new AttachmentUploadController();
        attachmentController.myfile=new Attachment();
        attachmentController.myfile.Body=Blob.valueOf('My test string');
        attachmentController.myfile.Name='test file';
        
        System.debug('File contents : '+ attachmentController.getmyfile());
        System.assert(attachmentController.getAccountId()==ac.Id);
        System.assert(attachmentController.getScorecardId()==scorecardType.Id);
        
        attachmentController.Savedoc();
    	
    	
    
    }
}