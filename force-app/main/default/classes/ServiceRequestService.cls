public without sharing class ServiceRequestService {

    private static final Set<String> ALLOWED_PRIORITIES = new Set<String>{
        'Low',
        'Medium',
        'High'
    };


    @AuraEnabled
    public static List<ServiceRequestDTO> createRequests(
        List<ServiceRequestDTO> requestDTOs
    ) {

        if (requestDTOs == null || requestDTOs.isEmpty()) {
            throw new AuraHandledException('Input cannot be empty');
        }

        List<Service_Request__c> requestsToInsert = new List<Service_Request__c>();

        for (ServiceRequestDTO dto : requestDTOs) {

            validateInput(dto);

            Service_Request__c requestRecord = dto.toSObject();

            requestRecord.Status__c = 'New';

            requestsToInsert.add(requestRecord);
        }

        insert requestsToInsert;

        return ServiceRequestDTO.of(requestsToInsert);
    }

  
    @AuraEnabled
    public static void resolveRequests(
        List<Id> requestIds,
        String resolutionNotes
    ) {

        if (requestIds == null || requestIds.isEmpty()) {
            throw new AuraHandledException('Request Ids cannot be empty');
        }

        List<Service_Request__c> requests = [
            SELECT Id,
                   Status__c,
                   Resolution_Notes__c
            FROM Service_Request__c
            WHERE Id IN :requestIds
        ];

        for (Service_Request__c requestRecord : requests) {

            requestRecord.Status__c = 'Resolved';
            requestRecord.Resolution_Notes__c = resolutionNotes;
        }

        update requests;
    }


    private static void validateInput(ServiceRequestDTO dto) {

        if (dto == null) {
            throw new AuraHandledException('Request cannot be null');
        }

        if (String.isBlank(dto.email)) {
            throw new AuraHandledException('Email is required');
        }

        if (String.isBlank(dto.priority)) {
            throw new AuraHandledException('Priority is required');
        }

        if (!ALLOWED_PRIORITIES.contains(dto.priority)) {
            throw new AuraHandledException('Invalid priority');
        }
    }
}