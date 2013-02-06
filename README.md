#qwikscoreLt
##Overview
QwikscoreLt is a combination Salesforce survey schema and corresponding jquerymobile page.   The image below shows 5 object that make up qwikscore and they are broken up into two domains.   The template domain has three objects that  allows users to create a Survey,  (QwikScore__c) , sections (QwikScore_Question_group__c), and the questions themselves (QwikScore_Questions__c).  

     
![image](https://s3.amazonaws.com/bowermanpublic/qwikscoreLt700.png)

By adding a custom button `https://na15.salesforce.com/apex/SurveyMobileKI?aid={!Account.Id}&stid=a04i0000000yPsI` on the account page you can pass in the account and QwickScore__c.id to instantiate the survey template for that account (QwikScore_Scorecard__c) and the set of questions (QwikScore_Questions_Answer__c) with blank answer values.    When the user fills out the survey from the SurveyMobile.page (via the button on account) they add values to the question_answer object.   When the form is submitted the instantiated survey  sums the final score and other statics of the question values.

---

##Installation
1. Use Ant to deploy the code in the src direcotry into your dev org
2. You may need to unhide the tabs in the app for your system Admin profile
3.  Go to the scorecard Type tab and add a new scorecard called test
4. next add two questions Groups related to that scorecard type called group1 and group2 with a group weight of 50 for each, make the sequence number 2 the second group
5. Next add two questions to each of the groups you created in the previous step, each with weight 50 (the question weight for each group should equal 100), select any value for Area and State, keep the minimum value 1 and maximum value 4, set the sequence number appropriately . 
6.  If you have done it correctly you should be able to hit 
      /apex/SurveyMobileKI?stid=[id of record in step 2][&aid=[any account id in your org]
7.  Once you fill this form out you should now have a new scorecard related to you account

__note that the SurveyMobileKI has the state and area listed as part of the questions where the SurveyMobile does not__

![image](https://s3.amazonaws.com/bowermanpublic/qwikscoreLt700.png)





based on [asset:](https://appirio.my.salesforce.com/apex/CMC_AssetView?id=a3E50000000CaZyEAK&sfdc.override=1 "Asset")

# dev5 is the latest development stream

