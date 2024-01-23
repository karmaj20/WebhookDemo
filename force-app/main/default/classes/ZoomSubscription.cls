@RestResource(urlMapping='/api/Webhooks/pushDetailsDemo/*')
global with sharing class ZoomSubscription {
    @HttpPost
    global static void handleNotification() {

        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;
        } catch(Exception e) {
            System.debug('Exception Happened: ' + e.getMessage());
        }
    }
}