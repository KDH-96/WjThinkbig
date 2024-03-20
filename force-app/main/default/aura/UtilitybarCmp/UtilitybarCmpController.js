({
    setUtilityIcon : function(component, event, helper) {
               
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(response => {
            if (typeof response !== 'undefined') {    
                utilityAPI.getEnclosingUtilityId().then(utilityId => {
                    utilityAPI.getUtilityInfo({utilityId}).then(response => {
                        var btnlabel = response.utilityLabel;
                        var eventHandler = function(response){
                            utilityAPI.minimizeUtility();
                            switch (btnlabel){
            					case '웅진 북클럽통' : 
                                    window.open("https://mirae.wjthinkbig.com/cmm/authentication/loginPage.lep",'웅진 북클럽통','top=300,left=700,width=1200,height=800,location=1,dependent=no,resizable=yes,toolbar=no,status=1,directories=no,menubar=no,scrollbars=no', false);
                                    break;
                            }
                        };
        
                        utilityAPI.onUtilityClick({ 
                            utilityId : utilityId,
                            eventHandler: eventHandler 
                        }).catch(error => helper.showToast(component, 'Error', 'Error', error));   
                    })
                    .catch(error => helper.showToast(component, 'Error', 'Error', error));   
                })
                .catch(error => helper.showToast(component, 'Error', 'Error', error));   
            }
        });  
    }
})