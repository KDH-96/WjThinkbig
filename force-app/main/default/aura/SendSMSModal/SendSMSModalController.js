({
	// quick action용
	getSMSTemplate: function (component, event, helper) {
		var parentId = component.get("v.recordId");

		var action = component.get("c.getSMSTemplateController");
		action.setParams({
			"parentId": parentId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var retMap = response.getReturnValue();

				var sendMobilePhone = retMap['sendMobilePhone'];
				component.set("v.sendMobilePhone",sendMobilePhone);

				var smsTemplatesMap = JSON.parse(retMap['smsTemplates']);
				var leadMap = JSON.parse(retMap['Lead']);
				var oppMap = JSON.parse(retMap['Opportunity']);
				
				var smsTemplates = [];
				var leads = [];

				for (var key in smsTemplatesMap) {
					smsTemplatesMap[key].forEach(function (template) {
						smsTemplates.push({
							"Id": template.Id,
							"Name": template.Name,
							"SMS_Title__c": template.SMS_Title__c,
							"SMS_Content_Message__c": template.SMS_Content_Message__c
						});
					});
				}

				for (var key in leadMap) {
					leadMap[key].forEach(function (e) {
						if (e.NOKNumber__c != null) {
							component.set("v.checkNOKNumber", true);
							leads.push({
								"Id": e.Id,
								"LastName": e.LastName,
								"MobilePhone": e.MobilePhone,
								"NOKNumber": e.NOKNumber__c,
								"OwnerName": e.Owner.Name
							});
						} else {
							component.set("v.checkNOKNumber", false);
							leads.push({
								"Id": e.Id,
								"LastName": e.LastName,
								"MobilePhone": e.MobilePhone,
								"OwnerName": e.Owner.Name
							});
						}
					});
				}
 				for (var key in oppMap) {
					oppMap[key].forEach(function (e) {
						if (e.NOKNumber__c != null) {
							component.set("v.checkNOKNumber", true);
							leads.push({
								"Id": e.Id,
								"LastName": e.fm_ParentName__c,
								"MobilePhone": e.ParentPhone__c,
								"NOKNumber": e.NOKNumber__c,
								"OwnerName": e.Owner.Name
							});
						} else {
							component.set("v.checkNOKNumber", false);
							leads.push({
								"Id": e.Id,
								"LastName": e.fm_ParentName__c,
								"MobilePhone": e.ParentPhone__c,
								"OwnerName": e.Owner.Name
							});
						}
					});
				} 
				component.set("v.leads", leads);
				component.set("v.receiveMobilePhone", leads[0].MobilePhone != null ? leads[0].MobilePhone : '');
				component.find("receiveMobile").set("v.value",  'LastName_'+leads[0].Id); 
				component.set("v.smsTemplates", smsTemplates);
			} else if (state === "ERROR") {
				// Handle errors
				console.error('error: ' + JSON.stringify(response.getError()));
			}
		});
		$A.enqueueAction(action);


		// 기본값 설정
		//component.set("v.receiveMobilePhone", '');
		// 선택된 값에서 Lead의 Id를 추출.
		//component.set("v.receiveMobilePhone", leads[0].MobilePhone);

		component.set("v.selectedTemplateId", 'none');
		component.set("v.selectedMessageTitleLength", 0);
		component.set("v.trimmedTitleLength", 0);
		component.set("v.selectedMessageLength", 0);
		component.set("v.trimmedMessageLength", 0);
		component.set("v.selectedMessage", "");
		component.set("v.selectedMessageTitle", "");
		component.set("v.isConfirmChecked", false);
	},

	closeModal: function (component) {
		$A.get("e.force:closeQuickAction").fire();
	},

	receiveMobileChange: function (component, event) {
		var selectedValue = event.getSource().get("v.value");
		var leads = component.get("v.leads");

		// 선택된 값에서 Lead의 Id를 추출.
		var selectedLeadId = selectedValue.split('_')[1];
		var selectedLead = leads.find(lead => lead.Id === selectedLeadId);

		if (selectedLead) {
			if (selectedValue.startsWith('LastName')) {
				component.set("v.receiveMobilePhone", selectedLead.MobilePhone);
			} else if (selectedValue.startsWith('NOKNumber')) {
				component.set("v.receiveMobilePhone", selectedLead.NOKNumber);
			}
		} else {
			// 선택된 Lead가 없을 때
			component.set("v.receiveMobilePhone", '');
		}

		var smsTemplates = component.get("v.smsTemplates");

		var selectedTemplateId = component.find("select1").get("v.value");
		var receiveMobile = component.find("receiveMobile").get("v.value");

		component.set("v.selectedTemplateId", selectedTemplateId);


		for (var i = 0; i < smsTemplates.length; i++) {
			if (smsTemplates[i].Id === selectedTemplateId) {
				var replaceMessage = smsTemplates[i].SMS_Content_Message__c;
				var replaceMessageTitle = smsTemplates[i].SMS_Title__c;
				if (receiveMobile.startsWith('LastName')) {
					// 부모의 이름이 선택된 경우
					replaceMessageTitle = replaceMessageTitle.replace(/<p[^>]*>/g, "").replace(/<\/p>/g, "");
					replaceMessage = replaceMessage
						.replace('{Lead.Name}', leads[0].LastName)
						.replace('{Lead.Owner.Name}', leads[0].OwnerName)
						.replace(/<span[^>]*>/g, '')
						.replace(/<\/span>/g, '')
						.replace(/<a.*?href=['"][^'"]*['"][^>]*>(.*?)<\/a>/g, '$1')
						.replace(/<br>/g, '')
						.replace(/<p[^>]*>/g, "")
						.replace(/<\/p>/g, "\n");

				} else {
					replaceMessageTitle = replaceMessageTitle.replace(/<p[^>]*>/g, "").replace(/<\/p>/g, "");
					replaceMessage = replaceMessage
						.replace('{Lead.Name}', 'OOO')
						.replace('{Lead.Owner.Name}', leads[0].OwnerName)
						.replace(/<span[^>]*>/g, '')
						.replace(/<\/?span>/g, '')
						.replace(/<a.*?href=['"][^'"]*['"][^>]*>(.*?)<\/a>/g, '$1')
						.replace(/<br>/g, '')
						.replace(/<p[^>]*>/g, "")
						.replace(/<\/p>/g, "\n");
				}
				component.set("v.selectedMessageTitle", replaceMessageTitle);
				component.set("v.selectedMessageTitleLength", replaceMessageTitle.length);
				component.set("v.trimmedTitleLength", replaceMessageTitle.length);
				component.set("v.selectedMessage", replaceMessage);
				component.set("v.selectedMessageLength", replaceMessage.length);
				component.set("v.trimmedMessageLength", replaceMessage.length);
				break;
			} 
		}


	},
	onMessageTemplateChange: function (component, event, helper) {

		var leads = component.get("v.leads");
		var smsTemplates = component.get("v.smsTemplates");

		var selectedTemplateId = component.find("select1").get("v.value");
		var receiveMobile = component.find("receiveMobile").get("v.value");
		component.set("v.selectedTemplateId", selectedTemplateId);

		for (var i = 0; i < smsTemplates.length; i++) {
			if (smsTemplates[i].Id === selectedTemplateId) {
				var replaceMessage = smsTemplates[i].SMS_Content_Message__c;
				var replaceMessageTitle = smsTemplates[i].SMS_Title__c;
				// 선택 전화번호 value에 따라 템플릿 수정.
				if (receiveMobile.startsWith('LastName')) {
					// 부모의 이름이 선택된 경우
					if(replaceMessageTitle != null){
						replaceMessageTitle = replaceMessageTitle.replace(/<p[^>]*>/g, "").replace(/<\/p>/g, "");
					}else{
						replaceMessageTitle=''
					}
					replaceMessage = replaceMessage
						.replace('{Lead.Name}', leads[0].LastName)
						.replace('{Lead.Owner.Name}', leads[0].OwnerName)
						.replace(/<span[^>]*>/g, '')
						.replace(/<\/?span>/g, '')
						.replace(/<a.*?href=['"][^'"]*['"][^>]*>(.*?)<\/a>/g, '$1')
						.replace(/<br>/g, '')
						.replace(/<p[^>]*>/g, "")
						.replace(/<\/p>/g, "\n");
				} else {
					if(replaceMessageTitle != null){
						replaceMessageTitle = replaceMessageTitle.replace(/<p[^>]*>/g, "").replace(/<\/p>/g, "");
					}else{
						replaceMessageTitle=''
					}
					replaceMessage = replaceMessage
						.replace('{Lead.Name}', 'OOO')
						.replace('{Lead.Owner.Name}', leads[0].OwnerName)
						.replace(/<span[^>]*>/g, '')
						.replace(/<\/?span>/g, '')
						.replace(/<a.*?href=['"][^'"]*['"][^>]*>(.*?)<\/a>/g, '$1')
						.replace(/<br>/g, '')
						.replace(/<p[^>]*>/g, "").replace(/<\/p>/g, "\n");
				}
				
				component.set("v.selectedMessageTitle", replaceMessageTitle);
				component.set("v.selectedMessageTitleLength", replaceMessageTitle.length);
				component.set("v.trimmedTitleLength", replaceMessageTitle.trim().length);
				component.set("v.selectedMessage", replaceMessage);
				component.set("v.selectedMessageLength", replaceMessage.length);
				component.set("v.trimmedMessageLength", replaceMessage.trim().length);
				
				break;
			} else {
				component.set("v.selectedMessageTitle", '');
				component.set("v.selectedMessageTitleLength", 0);
				component.set("v.trimmedTitleLength",0);
				component.set("v.selectedMessage", '');
				component.set("v.selectedMessageLength", 0);
				component.set("v.trimmedMessageLength", 0);
			}

		}
	},
	messageTitleChange:function (component, event, helper) {
		var titleLength = event.getSource().get("v.value").length;
		component.set("v.selectedMessageTitleLength", titleLength);
        var inputValue = event.getSource().get("v.value");
        var trimmedValueLength = inputValue.trim().length; // 문자열의 양 끝에서 공백을 제거합니다.
		component.set("v.trimmedTitleLength", trimmedValueLength);
	},
	messageChange: function (component, event) {
		var messageLength = event.getSource().get("v.value").length;
		component.set("v.selectedMessageLength", messageLength);
		
		var inputValue = event.getSource().get("v.value");
		var trimmedValueLength = inputValue.trim().length; // 문자열의 양 끝에서 공백을 제거합니다.
		
		component.set("v.trimmedMessageLength", trimmedValueLength);
		
	},

	confirmChecked: function (component) {
		var isChecked = component.find("checkConfirm").get("v.checked");
		component.set("v.isConfirmChecked", isChecked);
	},

	Send: function (component, event, helper) {
		helper.showSpinner(component);
		var parentId = component.get("v.recordId");

		var isChecked = component.find("checkConfirm").get("v.checked");

		var mobileNo = component.get("v.receiveMobilePhone");
		var smsTitle = component.get("v.selectedMessageTitle");
		//var smsTitle = 'SMS TEST';
		var smsMsg = component.get("v.selectedMessage");
		//var sendMobileNo = '15771500';
		var sendMobileNo = component.get("v.sendMobilePhone");
		var replacemobileNo = component.get("v.receiveMobilePhone").replace(/[^0-9]/g, '');
		var sendMobileNo = component.get("v.sendMobilePhone");
		//var replaceSendMobileNo = component.get("v.sendMobilePhone").replace(/[^0-9]/g, '');

		// "+"와 "82"를 제거하여 국가 코드를 지우기.
		var replaceSendMobileNo = sendMobileNo.replace(/\+?82\s?/, '');
		// sendMobileNo의 값에서 숫자만 추출하여 새로운 변수에 저장
		replaceSendMobileNo = replaceSendMobileNo.replace(/\D/g, '');
		if (replaceSendMobileNo.length === 10) {
			replaceSendMobileNo = '0' + replaceSendMobileNo;
		}

		console.log('smsTitle >> ', smsTitle);
		console.log('메세지 >> ', smsMsg);
		console.log('수신번호 replace >> ', replacemobileNo);
		console.log('발신번호 >> ', sendMobileNo);
		console.log('발신번호 replace >> ', replaceSendMobileNo);
		console.log('replacemobileNo.trim().length()> ', replacemobileNo.trim().length);
		/* 
		if(replacemobileNo.trim().length != 11 && replacemobileNo.trim().length != 10 ){
			helper.showToast(component, 'Error', '올바른 전화번호 양식이 아닙니다.');
			$A.get("e.force:closeQuickAction").fire();
		}else{
		 */	
			var action = component.get("c.SendSMS");
			//$A.get("e.force:closeQuickAction").fire();
			action.setParams({
				"mobileNo": replacemobileNo,
				"smsMsg": smsMsg,
				"smsTitle": smsTitle,
				//"sendMobileNo": sendMobileNo,
				"sendMobileNo": replaceSendMobileNo,
				"parentId" : parentId
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var retMap = response.getReturnValue();
					if(retMap['respCode'] ==='S'){
						helper.showToast(component, 'Success', '메세지가 전송되었습니다.');
						$A.get("e.force:closeQuickAction").fire();
					}else{
						helper.showToast(component, 'Error', '메세지가 전송에 오류가 있습니다.');
						$A.get("e.force:closeQuickAction").fire();
					}
					
				} else if (state === "ERROR") {
					// Handle errors
					console.error('error: ' + JSON.stringify(response.getError()));
				}
			});
			$A.enqueueAction(action);
		/* 	
		}
		 */

	},
})