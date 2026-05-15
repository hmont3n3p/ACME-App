public without sharing class ServiceRequestController {

    @AuraEnabled
    public static ServiceRequestDTO createRequest(
        ServiceRequestDTO requestDTO
    ) {

        List<ServiceRequestDTO> results =
            ServiceRequestService.createRequests(
                new List<ServiceRequestDTO>{ requestDTO }
            );

        return results[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<ServiceRequestDTO> getRecentRequests() {

        List<Service_Request__c> records = [
            SELECT Id,
                   Name,
                   Status__c,
                   Priority__c,
                   Customer_Email__c,
                   Description__c,
                   Resolution_Notes__c
            FROM Service_Request__c
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];

        return ServiceRequestDTO.of(records);
    }


    
    @AuraEnabled
    public static String askAgentforce(String userMessage) {
        if (String.isBlank(userMessage)) return '';
        
        try {
            Map<String, Object> flowInputs = new Map<String, Object>();
            flowInputs.put('vInput', userMessage);
            //if (Test.isRunningTest()) return 'Mock AI Response';
            Flow.Interview agentFlow = Flow.Interview.createInterview('Agentforce_Service_Proxy', flowInputs);
            agentFlow.start();
		
            return (String) agentFlow.getVariableValue('vOutput');
        } catch (Exception e) {
            throw new AuraHandledException('Error en Agentforce: ' + e.getMessage());
        }
    }
}