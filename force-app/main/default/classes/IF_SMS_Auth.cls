/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-21-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
public with sharing class IF_SMS_Auth {

        /**
     * @description sms 발송
     * @author dohun.kim
     * @param  mobileNo     수신번호
     * @param  smsMsg       메세지 본문 
     * @param  smsTitle     메세지제목
     * @param  sendMobileNo 발신번호
     * @return responseData
     */
    public static Map<String, Object> sendSMS(String mobileNo, String smsMsg, String smsTitle, String sendMobileNo) {
        
        Map<String, Object> responseData = new Map<String, Object>();
        try {
            Map<String, WjThinkbig_SMS_Dev__mdt> wtsd = WjThinkbig_SMS_Dev__mdt.getAll();
    
            String SMSUrl = wtsd.get('WjThinkbig_SMS_Auth_Info').SMSUrl__c;
            String RequestType = wtsd.get('WjThinkbig_SMS_Auth_Info').RequestType__c;
            String contentType = wtsd.get('WjThinkbig_SMS_Auth_Info').ContentType__c;
            String charset =  wtsd.get('WjThinkbig_SMS_Auth_Info').Charset__c;
            String authorizationToken = wtsd.get('WjThinkbig_SMS_Auth_Info').AuthorizationToken__c;

            Map<String, String> requestData = new Map<String, String>();
            requestData.put('mobileNo', mobileNo);
            requestData.put('smsTitle', smsTitle);
            requestData.put('smsMsg', smsMsg);
            requestData.put('sendMobileNo', sendMobileNo);
            String requestBody = JSON.serialize(requestData);
                
            System.debug('requestBody pretty >>> ' + JSON.serializePretty(requestBody));
            System.debug('EncodingUtil.urlEncode >>> ' + EncodingUtil.urlEncode(smsMsg, 'UTF-8'));
            
            String endpoint = SMSUrl;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(RequestType);
            request.setHeader('Content-Type', contentType);
            request.setHeader('charset', charset);
            request.setHeader('Authorization', authorizationToken);
            request.setTimeout(120000);
            request.setBody(requestBody);
                
            Http http = new Http();
            System.debug('Start >>>'+ Datetime.now());
            HttpResponse response = http.send(request);
                

            if (response.getStatusCode() == 200) {
                // 요청 성공
                System.debug('END >>>'+ Datetime.now());
                System.debug('요청 성공 >>> ');
                responseData.put('sendTime',Datetime.now());
                responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String respCode = (String) responseData.get('respCode');
                String respMsg = (String) responseData.get('respMsg');
                System.debug('SMS 발송 성공 - respCode: ' + respCode + ', respMsg: ' + respMsg);
            } else {
                // 요청 실패
                System.debug('SMS 발송 실패 - Status: ' + response.getStatus() + ', HTTP Status Code: ' + response.getStatusCode() + ', Response: ' + response.getBody());
                responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            }
        } catch(Exception e) {
            // 예외 처리
            System.debug('예외 발생: ' + e.getMessage());
            responseData.put('respCode', 'E');
            responseData.put('respMsg', '예외 발생: ' + e.getMessage());
        }

        return responseData;
      }  
  }