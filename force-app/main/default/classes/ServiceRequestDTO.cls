public class ServiceRequestDTO {

    @AuraEnabled public Id id { get; set; }
    @AuraEnabled public String email { get; set; }
    @AuraEnabled public String description { get; set; }
    @AuraEnabled public String priority { get; set; }
    @AuraEnabled public String resolutionNotes { get; set; }

    @AuraEnabled public String name { get; set; }
    @AuraEnabled public String status { get; set; }


    @AuraEnabled public Map<String, Object> meta;

  
    public ServiceRequestDTO() {
        this.meta = new Map<String, Object>();
    }

  
    public ServiceRequestDTO(Service_Request__c record) {
        this();
        this.id = record.Id;
        this.name = record.Name;
        this.email = record.Customer_Email__c;
        this.status = record.Status__c;
        this.priority = record.Priority__c;
        this.resolutionNotes=record.Resolution_Notes__c;
    }

   
    public static ServiceRequestDTO of(Service_Request__c record) {
        return new ServiceRequestDTO(record);
    }

  
    public static List<ServiceRequestDTO> of(List<Service_Request__c> records) {

        List<ServiceRequestDTO> result = new List<ServiceRequestDTO>();

        for (Service_Request__c record : records) {
            result.add(new ServiceRequestDTO(record));
        }

        return result;
    }

  
    public void putMeta(String key, Object value) {
        if (this.meta == null) {
            this.meta = new Map<String, Object>();
        }
        this.meta.put(key, value);
    }

   
    public Object getMeta(String key) {
        return (this.meta == null) ? null : this.meta.get(key);
    }

   
    public Service_Request__c toSObject() {

        Service_Request__c record = new Service_Request__c();

        record.Customer_Email__c = this.email;
        record.Description__c = this.description;
        record.Priority__c = this.priority;
        record.Resolution_Notes__c=this.resolutionNotes;

        return record;
    }
}