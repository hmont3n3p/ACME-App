@isTest
private class ServiceRequestServiceTest {

    @isTest
    static void testCreateRequestsSuccess() {
        ServiceRequestDTO dto = new ServiceRequestDTO();
        dto.email = 'test@example.com';
        dto.priority = 'High';
        dto.description = 'Test Description';
        
        Test.startTest();
        List<ServiceRequestDTO> results = ServiceRequestService.createRequests(new List<ServiceRequestDTO>{ dto });
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.isNotNull(results[0].id);
    }

    @isTest
    static void testResolveRequestsSuccess() {
        Service_Request__c req = new Service_Request__c(
            Customer_Email__c = 'test@test.com',
            Priority__c = 'Medium',
            Status__c = 'New'
        );
        insert req;

        Test.startTest();
        ServiceRequestService.resolveRequests(new List<Id>{ req.Id }, 'Fixed');
        Test.stopTest();

        Service_Request__c updated = [SELECT Status__c FROM Service_Request__c WHERE Id = :req.Id];
        Assert.areEqual('Resolved', updated.Status__c);
    }

    @isTest
    static void testCreateRequestsEmptyError() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            ServiceRequestService.createRequests(new List<ServiceRequestDTO>());
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
            // No validamos el texto exacto porque AuraHandledException lo oculta en tests
        }
        Assert.isTrue(exceptionThrown, 'Should have thrown an exception for empty input');
    }

    @isTest
    static void testValidationErrors() {
        // Test Email Required
        ServiceRequestDTO dto = new ServiceRequestDTO();
        dto.priority = 'High';
        
        Boolean emailException = false;
        try {
            ServiceRequestService.createRequests(new List<ServiceRequestDTO>{ dto });
        } catch (Exception e) {
            emailException = true;
        }
        Assert.isTrue(emailException, 'Should throw exception: Email required');

        // Test Invalid Priority
        dto.email = 'valid@test.com';
        dto.priority = 'Urgent'; 
        
        Boolean priorityException = false;
        try {
            ServiceRequestService.createRequests(new List<ServiceRequestDTO>{ dto });
        } catch (Exception e) {
            priorityException = true;
        }
        Assert.isTrue(priorityException, 'Should throw exception: Invalid priority');
    }

    @isTest
    static void testResolveRequestsEmptyError() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            ServiceRequestService.resolveRequests(null, 'Notes');
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Should throw exception for null IDs');
    }
}