public with sharing class AttachmentUploadController {

    /* Get Scorecard Id */
    public String getScorecardId() {
         return stid==null ? System.currentPagereference().getParameters().get('stid') : stid;
    }
    /* Get Account Id */
    string accid=null, stid=null;
    public String getAccountId() {
        return accid==null ? System.currentPagereference().getParameters().get('aid') : accid;
    }

   

    Public Attachment myfile;
    
    /* Create attachment */
    Public Attachment getmyfile()
    {
        myfile = new Attachment();
        return myfile;
    }
   
    /* Save attachment */
    Public Pagereference Savedoc()
    {
        accid = System.currentPagereference().getParameters().get('aid');
        stid = System.currentPagereference().getParameters().get('stid');
        Attachment a = new Attachment(parentId = accid, name=myfile.name, body = myfile.body);
         
         /* insert the attachment */
         try {
         insert a;}
         catch(Exception e){}
         finally {
             // free up the variable size in the view state
             myfile = new Attachment();
        }
        return null;
 
    } 
}