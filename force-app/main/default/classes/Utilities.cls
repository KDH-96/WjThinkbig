/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 01-29-2024
 * @last modified by  : ms.kim
**/
public with sharing class Utilities {
    public Utilities() {

    }
    
    public static string transWeekday(string week) {

        if(week == 'Sun'){
            return '일';
        }else if(week == 'Mon'){
            return '월';
        }else if(week == 'Tue'){
            return '화';
        }else if(week == 'Wed'){
            return '수';
        }else if(week == 'Thu'){
            return '목';
        }else if(week == 'Fri'){
            return '금';
        }else if(week == 'Sat'){
            return '토';
        }

        return null;

    }

    public static string transDateTimeFormat(String dtformat) {
        
        return dtformat.replace('AM', '(' + transWeekday(DateTime.now().format('E')) + ') 오전').replace('PM', '(' + transWeekday(DateTime.now().format('E')) + ') 오후');
    }

    public static string transDateTimeFormat(Datetime dt){

        return transDateTimeFormat(dt.format(Label.CLS_DateTime, String.valueOf(UserInfo.getTimeZone())));
    }
}