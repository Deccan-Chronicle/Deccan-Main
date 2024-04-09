public class AccountHelper {
    //Updating Account Rating
    public static void updateAccountRating(List<Account> theAccList){
        System.debug('Inside');
        if(!theAccList.isEmpty()){
            for(Account theAcc : theAccList){
                if(theAcc.Rating == 'Hot'){
                    theAcc.Type = 'Prospect';
                }
                else{
                    theAcc.Type = '';
                }
            }
        }       
    }
    
    //Sending chatter Post on Account Rating
    public static void chatterPostonAccountRatingUpdate(List<Id> theAccIdList) {
        
        List<Account> fetchedAccountList = [SELECT Id,Rating,Type FROM Account WHERE Id IN : theAccIdList];
        System.debug('fetchedAccountList'+fetchedAccountList);
        
        List<FeedItem> postsToInsert = new List<FeedItem>();
        
        for(Account theAcc : fetchedAccountList){
            if(theAcc.Rating != null){
                FeedItem feed = new FeedItem();
                feed.ParentId = theAcc.Id;
                feed.Body = 'The Account Rating has been Updated to '+theAcc.Rating ;
                postsToInsert.add(feed); 
                System.debug('postsToInsert'+postsToInsert);
            }
        }
        if(!postsToInsert.isEmpty()){
            Insert postsToInsert;
        }
    }  
    
    //Sending chatter Post Mentioning the Record Owner(Hyperlink) on Account SLA Update
    public static void chatterPostonAccountSLAUpdate(List<Id> theAccIdList){
        
        List<Account> theAccList = [SELECT Id,SLA__c,OwnerId FROM Account WHERE Id IN: theAccIdList];
        List<ConnectApi.FeedItemInput> feedItemsToInsert = new List<ConnectApi.FeedItemInput>();
        
        for(Account theAcc : theAccList){
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = theAcc.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            String postBody = 'A chatter post added because the Account SLA is updated to ' + theAcc.SLA__c ;
            textSegmentInput.text = postBody;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = theAcc.Id;
            
            feedItemsToInsert.add(feedItemInput);
        }
        if (!feedItemsToInsert.isEmpty() && !Test.isRunningTest()) {
            for (ConnectApi.FeedItemInput feedItem : feedItemsToInsert) {
                ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItem);
            }
        }
    }
}